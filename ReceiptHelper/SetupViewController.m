//
//  ViewController.m
//  ReceiptHelper
//
//  Created by ajmccall on 02/01/2015.
//  Copyright (c) 2015 AJMcCall LTD. All rights reserved.
//

#import "SetupViewController.h"
#import "PurchaseController.h"
#import "ValidatedViewController.h"

#pragma mark - ViewController PRIVATE INTERFACE
@interface SetupViewController ()<PurchaseControllerDelegate>

#pragma mark - IBOutlets
@property (weak, nonatomic) IBOutlet UITextField *iTunesSecretField;
@property (weak, nonatomic) IBOutlet UITextField *productIDField;
@property (weak, nonatomic) IBOutlet UISwitch *useIOStyleReceiptSwitch;
@property (weak, nonatomic) IBOutlet UIButton *validateProductButton;

@property (readonly, nonatomic) NSDictionary *purchaseControllerConfig;
@property (readonly, nonatomic) NSString *iTunesSecret;

@property (readonly, nonatomic) NSString *productId;
@property (readonly, nonatomic) BOOL useIOS6StyleReceipts;

@property (nonatomic, strong) PurchaseController *purchaseController;

@property (nonatomic, strong) NSData *receiptData;
@property (nonatomic, strong) NSData *receiptValidationResponseData;
@end

#pragma mark - ViewController IMPLEMENTATION

@implementation SetupViewController

#pragma mark - ViewController LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self commonInit];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)commonInit {
    
    self.purchaseController = [[PurchaseController alloc] init];
    self.purchaseController.delegate = self;
    
    self.iTunesSecretField.text = self.iTunesSecret;
    self.productIDField.text = self.productId;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self alertIfNoITunesSecretIsFound];
}

#pragma mark - Custom Properties

- (NSDictionary *)purchaseControllerConfig {
    NSString *pathToConfig = [[NSBundle mainBundle] pathForResource:@"purchaseController" ofType:@"plist"];
    return [NSDictionary dictionaryWithContentsOfFile:pathToConfig];
}

- (NSString *)iTunesSecret {
    return self.purchaseControllerConfig[@"iTunesSecret"];
}

- (NSString *)productId {
    return self.purchaseControllerConfig[@"productId"];
}

- (BOOL)useIOS6StyleReceipts {
    return [self.useIOStyleReceiptSwitch isOn];
}

#pragma mark - IBActions

- (IBAction)validateProductAction:(id)sender {
    
    NSString *productId = self.productIDField.text;
    
    if(self.useIOStyleReceiptSwitch) {
        
        [self.purchaseController validateIOS6StyleReceiptForProdcutID:productId];
    } else {
        
        [self.purchaseController validateReceiptForProdcutID:productId];
    }
 
    [self showProcessStarted];
}

- (void)showProcessStarted {
    
    self.validateProductButton.enabled = NO;
}

- (void)showProcessEnded {
    
    self.validateProductButton.enabled = YES;
}

#pragma mark - PurchaseControllerDelegate Methods

- (void)purchaseController:(PurchaseController *)controller
          validatedReciept:(NSData *)receiptData
               andResponse:(NSData *)response {
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        [self showProcessEnded];
        
        self.receiptData = receiptData;
        self.receiptValidationResponseData = response;
        [self performSegueWithIdentifier:@"showResults"
                                  sender:self];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.destinationViewController isKindOfClass:[ValidatedViewController class]]) {
        
        ValidatedViewController *validatedViewController = (ValidatedViewController *)segue.destinationViewController;
        validatedViewController.receiptValidationData = self.receiptValidationResponseData;
        validatedViewController.receiptData = self.receiptData;
    }
}

- (void)purchaseController:(PurchaseController *)controller
           failedWithError:(NSError *)error {
    
    [self showProcessEnded];
    
    [[[UIAlertView alloc] initWithTitle:error.localizedDescription
                                message:error.localizedRecoverySuggestion
                               delegate:nil
                      cancelButtonTitle:@"Got it"
                      otherButtonTitles:nil] show];
}

#pragma mark - Setup Alert

- (void)alertIfNoITunesSecretIsFound {
    
    if(!self.iTunesSecret || [self.iTunesSecret isEqualToString:@""]) {
    
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert.noItunesSecretFound.title", nil)
                                    message:NSLocalizedString(@"alert.noItunesSecretFound.message", nil)
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:nil] show];
    }
}



@end
