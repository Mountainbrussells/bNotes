//
//  ShareViewController.m
//  bNotesShare
//
//  Created by Ben Russell on 10/30/15.
//  Copyright © 2015 Ben Russell. All rights reserved.
//

#import "ShareViewController.h"
#import "PersistenceController.h"


@interface ShareViewController ()

@property (nonatomic, strong) PersistenceController *persistenceController;

@end

@implementation ShareViewController

- (void)viewDidLoad {
    self.persistenceController = [[PersistenceController alloc] initWithCallback:nil];
    
}

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
    }
}

- (BOOL)isContentValid {
    // Do validation of contentText and/or NSExtensionContext attachments here
    NSInteger messageLength = self.contentText.length;
    
    if (messageLength > 0) {
        return YES;
    }
    return NO;
}

- (void)didSelectPost {
    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
    [_detailItem setValue:self.contentText forKey:@"text"];
    
    [self saveContext];
    
    // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}



- (void) saveContext {
   
    [self.persistenceController save];
    
}

- (NSArray *)configurationItems {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    return @[];
}

@end
