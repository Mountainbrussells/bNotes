//
//  PersistenceController.m
//  bNotes
//
//  Created by Ben Russell on 11/2/15.
//  Copyright © 2015 Ben Russell. All rights reserved.
//

#import "PersistenceController.h"

@interface PersistenceController ()

@property (strong, readwrite) NSManagedObjectContext *managedObjectContext;
@property (strong) NSManagedObjectContext *privateContext;

@property (assign) BOOL useiCloud;

@property (copy) InitCallbackBlock initCallback;

- (void)initializeCoreData;

@end

@implementation PersistenceController

- (id)initWithCallback:(InitCallbackBlock)callback
{
    if (!(self = [super init])) return nil;
    
    [self setInitCallback:callback];
    self.useiCloud = NO;
    [self initializeCoreData];
    
    return self;
}

- (void)initializeCoreData
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    if ([self managedObjectContext]) return;
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"bNotes" withExtension:@"momd"];
     NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    
    [self setManagedObjectContext:[[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType]];
    
    [self setPrivateContext:[[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType]];
    [[self privateContext] setPersistentStoreCoordinator:coordinator];
    [self.privateContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    [[self managedObjectContext] setParentContext:[self privateContext]];
    
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.BenRussell.bnotes"];
    
    if ([defaults boolForKey:@"useiCloudStore"]) {
        // Subscribe to iCloud Notifications
        NSNotificationCenter *defaulCenter = [NSNotificationCenter defaultCenter];
        [defaulCenter addObserver:self
                         selector:@selector(storesWillChange:)
                             name:NSPersistentStoreCoordinatorStoresWillChangeNotification
                           object:self.privateContext.persistentStoreCoordinator];
        
        [defaulCenter addObserver:self
                         selector:@selector(storesDidChange:)
                             name:NSPersistentStoreCoordinatorStoresDidChangeNotification
                           object:self.privateContext.persistentStoreCoordinator];
        [defaulCenter addObserver:self
                         selector:@selector(persistentStoreDidImportUbiquitousContentChanges:)
                             name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
                           object:self.privateContext.persistentStoreCoordinator];
        
        
        
        NSURL *documentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        
        NSURL *storeURL = [documentsDirectory URLByAppendingPathComponent:@"CoreData.sqlite"];
        
        NSError *error;
        
        
        NSDictionary *storeOptions = @{NSPersistentStoreUbiquitousContentNameKey: @"bNotesCloudStore"};
     
        
        [self.privateContext.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                     configuration:nil
                                                                               URL:storeURL
                                                                           options:storeOptions
                                                                             error:&error];
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSPersistentStoreCoordinator *psc = [[self privateContext] persistentStoreCoordinator];
        
        NSMutableDictionary *options = [NSMutableDictionary dictionary];
        options[NSMigratePersistentStoresAutomaticallyOption] = @YES;
        options[NSInferMappingModelAutomaticallyOption] = @YES;
        options[NSSQLitePragmasOption] = @{ @"journal_mode":@"DELETE" };
        
        
        
        
        NSURL *storeURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.BenRussell.bnotes"];
        storeURL = [storeURL URLByAppendingPathComponent:@"BenRussell.sqlite"];
        NSError *error = nil;
        NSString *failureReason = @"There was an error creating or loading the application's saved data.";
        if (![psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
            // Report any error we got.
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
            dict[NSLocalizedFailureReasonErrorKey] = failureReason;
            dict[NSUnderlyingErrorKey] = error;
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        if (![self initCallback]) return;
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self initCallback]();
        });
    });
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initializeiCloud:) name:@"UseiCloud" object:nil];
}

- (void)save;
{
    if (!([[self privateContext] hasChanges] || [[self managedObjectContext] hasChanges])) return;
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [[self managedObjectContext] performBlockAndWait:^{
        NSError *error;
        
        NSString *failureReason = @"There was an error saving the application's data.";
        
        if (![[self managedObjectContext] save:&error]) {
            // Report any error we got.
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
            dict[NSLocalizedFailureReasonErrorKey] = failureReason;
            dict[NSUnderlyingErrorKey] = error;
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        [[self privateContext] performBlockAndWait:^{
            NSError *privateError;
            if (![[self privateContext] save:&privateError]) {
                // Report any error we got.
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
                dict[NSLocalizedFailureReasonErrorKey] = failureReason;
                dict[NSUnderlyingErrorKey] = error;
                privateError = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
                // Replace this with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }];
    }];
}

- (void)initializeiCloud:(id)sender
{

    // Subscribe to iCloud Notifications
    NSNotificationCenter *defaulCenter = [NSNotificationCenter defaultCenter];
    [defaulCenter addObserver:self
                     selector:@selector(storesWillChange:)
                         name:NSPersistentStoreCoordinatorStoresWillChangeNotification
                       object:self.privateContext.persistentStoreCoordinator];
    
    [defaulCenter addObserver:self
                     selector:@selector(storesDidChange:)
                         name:NSPersistentStoreCoordinatorStoresDidChangeNotification
                       object:self.privateContext.persistentStoreCoordinator];
    [defaulCenter addObserver:self
                     selector:@selector(persistentStoreDidImportUbiquitousContentChanges:)
                         name:NSPersistentStoreDidImportUbiquitousContentChangesNotification
                       object:self.privateContext.persistentStoreCoordinator];
    
    NSPersistentStore *currentStore = self.privateContext.persistentStoreCoordinator.persistentStores.lastObject;
   
    NSURL *documentsDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
    NSURL *storeURL = [documentsDirectory URLByAppendingPathComponent:@"CoreData.sqlite"];
    
    NSError *error;
    
    
    NSDictionary *storeOptions = @{NSPersistentStoreUbiquitousContentNameKey: @"bNotesCloudStore"};
    
    
    
    [self.privateContext.persistentStoreCoordinator removePersistentStore:currentStore error:&error];
    
    [self.privateContext.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                 configuration:nil
                                                                           URL:storeURL
                                                                       options:storeOptions
                                                                         error:&error];
    
    
//    [self.privateContext.persistentStoreCoordinator migratePersistentStore:currentStore
//                                                                     toURL:storeURL
//                                                                   options:storeOptions
//                                                                  withType:NSSQLiteStoreType
//                                                                     error:&error];
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.BenRussell.bNotes"];
    
    [defaults setBool:true forKey:@"useiCloudStore"];
    [defaults synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"iCloudDataChanged" object:self];
    
}

- (void) storesWillChange:(NSNotification *)note
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    if ([self.privateContext hasChanges]) {
        NSError *error;
        if (![self.privateContext save:&error]) {
            NSLog(@"Save error: %@", error);
        } else {
            [self.privateContext reset];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"iCloudDataChanged" object:self];
}

- (void) storesDidChange:(NSNotification *)note
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self save];
    [self.privateContext reset];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"iCloudDataChanged" object:self];
}


- (void) persistentStoreDidImportUbiquitousContentChanges: (NSNotification *)note
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    
    [self.privateContext performBlock:^{
        [self.privateContext mergeChangesFromContextDidSaveNotification:note];
        [self save];
        [self.privateContext reset];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"iCloudDataChanged" object:self];
    }];
}
@end
