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
@property (strong, nonatomic) NSManagedObject *object;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation ShareViewController

- (void)viewDidLoad {
    self.persistenceController = [[PersistenceController alloc] initWithCallback:nil];
   
    
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
    self.object = object;
    
    [self.object setValue:self.contentText forKey:@"text"];
    
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
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
    
    // Save the context.
    [self.persistenceController save];
    return newManagedObject;
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:self.persistenceController.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:1];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
    
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.persistenceController.managedObjectContext sectionNameKeyPath:nil cacheName:@"AllNotes"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
   
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}

@end
