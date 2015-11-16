//
//  ShareViewController.m
//  bNotesShare
//
//  Created by Ben Russell on 10/30/15.
//  Copyright © 2015 Ben Russell. All rights reserved.
//

#import "ShareViewController.h"
#import "PersistenceController.h"
@import MobileCoreServices;


@interface ShareViewController ()

@property (nonatomic, strong) PersistenceController *persistenceController;
@property (strong, nonatomic) NSString *originalContentTextForTitle;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (strong, nonatomic) NSString *urlString;

@end

@implementation ShareViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.BenRussell.bnotes"];
    [defaults synchronize];
    
    self.persistenceController = [[PersistenceController alloc] initWithCallback:nil];
    self.originalContentTextForTitle = self.contentText;
    NSExtensionItem *item = self.extensionContext.inputItems.firstObject;
    NSItemProvider *itemProvider = item.attachments.firstObject;
    if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL]) {
        [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeURL options:nil completionHandler:^(NSURL *url, NSError *error) {
            self.urlString = url.absoluteString;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *title = self.contentText;
                NSString *content = self.urlString;
                self.textView.text = [NSString stringWithFormat:@"%@ - %@", title, content];
            });
//            NSManagedObject *object = [self insertNewObject];
//            self.object = object;
//            
//            [self.object setValue:self.contentText forKey:@"title"];
//            [self.object setValue:(NSString *)self.urlString forKey:@"text"];
//            
//            [self saveContext];
        }];
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
    
    
    
            NSManagedObject *object = [self insertNewObject];
    
            
            [object setValue:self.originalContentTextForTitle forKey:@"title"];
            [object setValue:self.textView.text forKey:@"text"];
            
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

- (NSManagedObject *)insertNewObject {
    NSManagedObjectContext *context = [self.persistenceController managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:self.persistenceController.managedObjectContext];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
    
    // Save the context.
    [self.persistenceController save];
    return newManagedObject;
}

@end
