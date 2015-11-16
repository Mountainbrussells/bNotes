//
//  MasterViewController.m
//  bNotes
//
//  Created by Ben Russell on 10/28/15.
//  Copyright © 2015 Ben Russell. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"



@interface MasterViewController () <UISearchDisplayDelegate, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating, UISearchDisplayDelegate>

@property (strong, nonatomic) NSMutableArray *fetchedObjects;
@property (strong, nonatomic) NSMutableArray *filteredObjects;
@property (strong, nonatomic) UISearchController *searchController;

@end

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    self.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
    self.navigationItem.leftItemsSupplementBackButton = true;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    [self.searchController.searchBar sizeToFit];
        
    
    self.fetchedObjects = [[NSMutableArray alloc] initWithArray:self.fetchedResultsController.fetchedObjects];
    self.filteredObjects = [[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iCloudDataChanged:) name:@"iCloudDataChanged" object:nil];
    

    


}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [super viewDidAppear:animated];
    
    // iCloud permissions
    NSFileManager* fileManager = [NSFileManager defaultManager];
    id currentiCloudToken = fileManager.ubiquityIdentityToken;
    
    if (currentiCloudToken) {
        NSData *newTokenData = [NSKeyedArchiver archivedDataWithRootObject: currentiCloudToken];
        [[NSUserDefaults standardUserDefaults] setObject: newTokenData forKey: @"com.apple.bNotes.UbiquityIdentityToken"];
    } else {
        [[NSUserDefaults standardUserDefaults]
         removeObjectForKey: @"com.apple.bNotes.UbiquityIdentityToken"];
    }
    
    [[NSNotificationCenter defaultCenter]
     addObserver: self
     selector: @selector (iCloudAccountAvailabilityChanged:)
     name: NSUbiquityIdentityDidChangeNotification
     object: nil];
    
    BOOL notFirstLaunchWithiCloudAvailable = [[NSUserDefaults standardUserDefaults] boolForKey:@"notFirstLaunchWithiCloudAvailable"];
    
    if (currentiCloudToken && !notFirstLaunchWithiCloudAvailable) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Choose Storage Option"
                                                                       message:@"Should documents be stored in iCloud and available on all your devices?"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction *action)
                                       {
                                           NSLog(@"Cancel action");
                                       }];
        
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"OK action");
                                       [[NSNotificationCenter defaultCenter] postNotificationName:@"UseiCloud" object:self];
                                       NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.BenRussell.bnotes"];
                                       
                                       [defaults setBool:true forKey:@"useiCloudStore"];
                                       [defaults synchronize];
                                   }];
        
        [alert addAction:cancelAction];
        [alert addAction:okAction];
        
        
        [self presentViewController:alert animated:YES completion:nil];
        
        [[NSUserDefaults standardUserDefaults] setValue:@TRUE forKey:@"notFirstLaunchWithiCloudAvailable"];
    }
}

- (void)applicationWillEnterForeground:(NSNotification *) note
{
    self.fetchedResultsController = nil;
    
    self.fetchedObjects = [[NSMutableArray alloc] initWithArray:self.fetchedResultsController.fetchedObjects];
    
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];

    
    self.fetchedObjects = [[NSMutableArray alloc] initWithArray:self.fetchedResultsController.fetchedObjects];
   
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"addNote"]) {
        NSManagedObject *object = [self insertNewObject];
        DetailViewController *controller = (DetailViewController *)[segue destinationViewController];
        controller.persistenceController = self.persistenceController;
        [controller setDetailItem:object];
        
    }
    
    if ([[segue identifier] isEqualToString:@"showNote"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        DetailViewController *controller = (DetailViewController *)[segue destinationViewController];
        controller.persistenceController = self.persistenceController;
        [controller setDetailItem:object];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
        
        
    }
}

#pragma mark - Exit segue

- (IBAction) detailControllerSaved:(UIStoryboardSegue *)segue {
    
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (self.searchController.active) {
        return self.filteredObjects.count;
    } else {
        id<NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
        
        return [sectionInfo numberOfObjects];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;

}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.persistenceController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
            
        [self.persistenceController save];
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
   
    
    if (self.searchController.active) {
        if (self.filteredObjects.count > 0) {
            
            NSManagedObject *object = [self.filteredObjects objectAtIndex:indexPath.row];
            cell.textLabel.text = [object valueForKey:@"title"];
            if ([cell.textLabel.text  isEqual:@""]) {
                cell.textLabel.text = @"NO TITLE";
            }
            cell.detailTextLabel.text = [object valueForKey:@"text"];
            if ([cell.detailTextLabel.text isEqual:@""]) {
                cell.detailTextLabel.text = @"NO CONTENT";
            }
        }
    } else {
        NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
        cell.textLabel.text = [object valueForKey:@"title"];
        if ([cell.textLabel.text  isEqual:@""]) {
            cell.textLabel.text = @"NO TITLE";
        }
        cell.detailTextLabel.text = [object valueForKey:@"text"];
        if ([cell.detailTextLabel.text isEqual:@""]) {
            cell.detailTextLabel.text = @"NO CONTENT";
        }
    }
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
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
    
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.persistenceController.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    self.fetchedResultsController.delegate = self;
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            return;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    
    [self.tableView endUpdates];
    
}

- (void)iCloudDataChanged:(NSNotification *)note
{
    
    [self.fetchedResultsController performFetch:nil];
    [self.tableView reloadData];
}

#pragma mark - Filtering

- (void)filterNotes:(NSArray *)notes forSearchText:(NSString *)searchText
{
    
    
    NSPredicate *textPredicate = [NSPredicate predicateWithFormat:
                              @"text CONTAINS[cd] %@", searchText];

    NSPredicate *titlePredicate = [NSPredicate predicateWithFormat:
                              @"title CONTAINS[cd] %@", searchText];
    
    NSPredicate *predicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[textPredicate, titlePredicate]];
    
    
    self.filteredObjects = [[NSMutableArray alloc] initWithArray:[notes filteredArrayUsingPredicate:predicate]];
    
}



#pragma mark - UISearchControllerDelegates
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    
    NSString *searchString = searchController.searchBar.text;
    NSArray *notes = [[NSArray alloc] initWithArray: self.fetchedResultsController.fetchedObjects];
    [self filterNotes:notes forSearchText:searchString];
    [self.tableView reloadData];
}


/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
*/

@end
