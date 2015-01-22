//
//  PurchaseController.m
//  ReceiptHelper
//
//  Created by alasdaiir on 02/01/2015.
//

#import "PurchaseController.h"

#import <StoreKit/StoreKit.h>
#import <StoreKit/SKPaymentTransaction.h>

#pragma mark - Type Definitions
typedef void (^ITunesReceiptValidationResponse)(NSURLResponse *response, NSData *data, NSError *connectionError);


#pragma mark - PurchaseController INTERFACE

@interface PurchaseController() <SKPaymentTransactionObserver, SKProductsRequestDelegate>

@property (nonatomic, assign) BOOL useIOS6StyleReceipts;
@property (readonly, nonatomic) NSDictionary *purchaseControllerConfig;
@property (readonly, nonatomic) NSString *iTunesSecret;

@property (nonatomic, readonly) NSError *canMakePaymentsError;
@property (nonatomic, readonly) NSError *noProductIDError;
@property (nonatomic, readonly) NSError *paymentCancelledError;
@property (nonatomic, readonly) NSError *connectionError;
@property (nonatomic, readonly) NSError *noJSONError;

@end

#pragma mark - MQPurchaseController IMPLEMENTATION

@implementation PurchaseController

#pragma mark - Init

- (id)init {
    
    if (self = [super init]) {
        
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    
    return self;
}

- (void)dealloc {
    
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

#pragma mark - Custom Properties

- (NSDictionary *)purchaseControllerConfig {
    NSString *pathToConfig = [[NSBundle mainBundle] pathForResource:@"purchaseController" ofType:@"plist"];
    return [NSDictionary dictionaryWithContentsOfFile:pathToConfig];
}

- (NSString *)iTunesSecret {
    return self.purchaseControllerConfig[@"iTunesSecret"];
}

- (NSError *)canMakePaymentsError {
    
    return [self makeErrorWithCode:@(100)];
}

- (NSError *)noProductIDError {
    return [self makeErrorWithCode:@(101)];
}

- (NSError *)paymentCancelledError {
    
    return [self makeErrorWithCode:@(102)];
}

- (NSError *)connectionError {
    
    return [self makeErrorWithCode:@(103)];
}

-(NSError *)noJSONError {
    
    return [self makeErrorWithCode:@(104)];
}

- (NSError *)makeErrorWithCode:(NSNumber *)errorCode {
    
    NSString *descriptionKey = [NSString stringWithFormat:@"E%@.description", errorCode.stringValue];
    NSString *suggestionKey = [NSString stringWithFormat:@"E%@.suggestion", errorCode.stringValue];
    
    return [NSError errorWithDomain:@"ReceiptValidation" code:errorCode.integerValue userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(descriptionKey, @""),
                                                                                                NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(suggestionKey, @"")}];
    
}


#pragma mark - Purchase Method

- (void)validateReceiptForProdcutID:(NSString *)productID {
    
    self.useIOS6StyleReceipts = NO;
    [self startPurchaseRequestForProduct:productID];
}

- (void)validateIOS6StyleReceiptForProdcutID:(NSString *)productID {
    
    self.useIOS6StyleReceipts = YES;
    [self startPurchaseRequestForProduct:productID];
}

- (void)startPurchaseRequestForProduct:(NSString *)productID {
    
    NSSet *productIDs = [NSSet setWithObject:productID];
    
    if ([SKPaymentQueue canMakePayments]) {
        
        SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:productIDs];
        request.delegate = self;
        
        [request start];
    } else {
        
        [self.delegate purchaseController:self failedWithError:self.canMakePaymentsError];
    }
}

#pragma mark - SKRequest delegate methods

- (void)productsRequest:(SKProductsRequest *)request
     didReceiveResponse:(SKProductsResponse *)response {
    
    if (response.products.count > 0) {
        SKProduct *product = [response.products firstObject];
        [self purchaseProduct:product];
    } else {
        
        [self.delegate purchaseController:self failedWithError:self.noProductIDError];
    }
}

- (void)purchaseProduct:(SKProduct *)product {
    
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    [self.delegate purchaseController:self failedWithError:error];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    
    for (SKPaymentTransaction *transaction in transactions) {
        
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing: {
                break;
            }
            case SKPaymentTransactionStatePurchased: {
                
                [self validateReceipt:transaction];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            }
            case SKPaymentTransactionStateFailed: {
                
                [self failedTransaction:transaction];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            }
            case SKPaymentTransactionStateRestored: {
                
                [self validateReceipt:transaction];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            }
            default:
                break;
                
        }
    }
}

#pragma mark - Validate Receipt
- (void)validateReceipt:(SKPaymentTransaction *)transaction {
    
    NSError *error;
    NSData *requestData = [self receiptDataFromTransaction:transaction
                                                     error:&error];
    
    if (error) {
        [self.delegate purchaseController:self failedWithError:error];
    } else {
        [self sendToSandboxServerReceiptData:requestData];
    }
}

#pragma - Receipt Data Creation

- (NSData *)receiptDataFromTransaction:(SKPaymentTransaction *)transaction error:(NSError **)error {
    
    NSString *receiptBase64 = [self base64EncodedReceiptUsingTransaction:transaction];
    
    NSDictionary *requestContents = @{@"receipt-data": receiptBase64,
                                      @"password" : self.iTunesSecret};
    
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestContents
                                                          options:0
                                                            error:error];
    return requestData;
}

- (NSString *)base64EncodedReceiptUsingTransaction:(SKPaymentTransaction *)transaction {
    
    NSData *receiptData;
    if(self.useIOS6StyleReceipts) {
        
        receiptData = [self recieptFromTransaction:transaction];
    } else {
        
        receiptData = [self receiptFromBundle];
    }
    
    return [receiptData base64EncodedStringWithOptions:0];
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
- (NSData *)recieptFromTransaction:(SKPaymentTransaction *)transaction {
    return transaction.transactionReceipt;
}
#pragma GCC diagnostic pop

- (NSData *)receiptFromBundle {
    
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    return [NSData dataWithContentsOfURL:receiptURL];
}

#pragma mark -

- (void)sendToSandboxServerReceiptData:(NSData *)receiptData {
    
    NSURLRequest *storeRequest = [self storeRequestWithBodyData:receiptData];
    
    // Make a connection to the iTunes Store on a background queue.
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:storeRequest
                                       queue:queue
                           completionHandler:[self requestResponseCallback:receiptData]];
}

- (NSURLRequest *)storeRequestWithBodyData:(NSData *)bodyData {
    
    // Create a POST request with the receipt data.
    NSURL *storeURL = [NSURL URLWithString:@"https://sandbox.itunes.apple.com/verifyReceipt"];
    NSMutableURLRequest *storeRequest = [NSMutableURLRequest requestWithURL:storeURL];
    [storeRequest setHTTPMethod:@"POST"];
    [storeRequest setHTTPBody:bodyData];
    
    return storeRequest;
}

- (ITunesReceiptValidationResponse)requestResponseCallback:(NSData *)receiptData {
    
    return ^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if (connectionError) {
            
            [self.delegate purchaseController:self failedWithError:self.connectionError];
        } else {
            
            [self.delegate purchaseController:self validatedReciept:receiptData andResponse:data];
        }
    };
}

#pragma mark - Failed Transaction Helper
- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    if (transaction.error.code == SKErrorPaymentCancelled) {
        
        [self.delegate purchaseController:self failedWithError:self.paymentCancelledError];
    } else {
        
        [self.delegate purchaseController:self failedWithError:transaction.error];
    }
}

@end
