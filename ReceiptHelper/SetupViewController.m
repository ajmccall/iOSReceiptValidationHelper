//
//  ViewController.m
//  ReceiptHelper
//
//  Created by alasdaiir on 02/01/2015.
//  Copyright (c) 2015 Musicqubed LTD. All rights reserved.
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
    return self.productIDField.text;
}

- (BOOL)useIOS6StyleReceipts {
    return [self.useIOStyleReceiptSwitch isOn];
}

#pragma mark - IBActions

- (IBAction)validateProductAction:(id)sender {
    
    if(self.useIOStyleReceiptSwitch) {
        
        [self.purchaseController validateIOS6StyleReceiptForProdcutID:self.productId];
    } else {
        
        [self.purchaseController validateReceiptForProdcutID:self.productId];
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
      validateSuccessfully:(NSData *)responseData {
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        [self showProcessEnded];
        [self performSegueWithIdentifier:@"showResults"
                                  sender:responseData];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.destinationViewController isKindOfClass:[ValidatedViewController class]]) {
        
        ValidatedViewController *validatedViewController = (ValidatedViewController *)segue.destinationViewController;
        validatedViewController.receiptValidationData = sender;
    }
}

- (void)purchaseController:(PurchaseController *)controller
           failedWithError:(NSError *)error {
    
    [self showProcessEnded];
    
    [[[UIAlertView alloc] initWithTitle:error.localizedDescription
                                message:error.localizedRecoverySuggestion
                               delegate:nil
                      cancelButtonTitle:@"Thanks"
                      otherButtonTitles:nil] show];
}



@end