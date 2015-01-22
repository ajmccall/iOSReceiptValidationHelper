//
//  ValidatedViewController.m
//  ReceiptHelper
//
//  Created by ajmccall on 02/01/2015.
//  Copyright (c) 2015 AJMcCall LTD. All rights reserved.
//

#import "ValidatedViewController.h"
#import <MessageUI/MessageUI.h>

typedef void (^MailComposerCompleted)();

@interface ValidatedViewController ()<MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *validatedJSONTextView;
@property (readonly, nonatomic) NSString *receiptValidationDataAsString;

@end

@implementation ValidatedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateViews];
}

#pragma mark - Custom Property Acessors

- (NSString *)receiptValidationDataAsString {
    return [[NSString alloc] initWithData:self.receiptValidationData encoding:NSUTF8StringEncoding];

}

- (void)setReceiptValidationData:(NSData *)receiptValidationData {

    _receiptValidationData = receiptValidationData;
    [self updateViews];
}

- (void)updateViews {
    
    self.validatedJSONTextView.text = self.receiptValidationDataAsString;
}

- (IBAction)emailResultAction:(id)sender {
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    [picker setSubject:@"Receipt Validation"];
    [picker setMessageBody:NSLocalizedString(@"email.body", @"") isHTML:NO];
    [picker addAttachmentData:self.receiptValidationData mimeType:@"application/json" fileName:@"iTunesResponse"];
    [picker addAttachmentData:self.receiptData mimeType:@"application/octet-stream" fileName:@"iTunesReceipt"];
    [self presentViewController:picker
                       animated:YES
                     completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {

    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
