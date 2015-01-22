//
//  PurchaseController.h
//  ReceiptHelper
//
//  Created by alasdaiir on 02/01/2015.
//  Copyright (c) 2015 Musicqubed LTD. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PurchaseControllerDelegate;

#pragma mark - PurchaseController INTERFACE

@interface PurchaseController : NSObject

@property (nonatomic, weak) id<PurchaseControllerDelegate> delegate;

- (void)validateReceiptForProdcutID:(NSString *)productID;
- (void)validateIOS6StyleReceiptForProdcutID:(NSString *)productID;

@end

#pragma mark - PurchaseControllerDelegate PROTOCOL

@protocol PurchaseControllerDelegate <NSObject>

- (void)purchaseController:(PurchaseController *)controller
          validatedReciept:(NSData *)receiptData
               andResponse:(NSData *)response;

- (void)purchaseController:(PurchaseController *)controller
           failedWithError:(NSError *)error;

@end
