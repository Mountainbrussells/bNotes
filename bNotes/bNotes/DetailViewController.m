//
//  DetailViewController.m
//  bNotes
//
//  Created by Ben Russell on 10/28/15.
//  Copyright © 2015 Ben Russell. All rights reserved.
//

#import "DetailViewController.h"
#import "AppDelegate.h"
#import "MasterViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface DetailViewController ()<UITextViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (assign) BOOL iPadViewLaidOut;

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
    
        
        // Update the view.
        if (!self.iPadViewLaidOut) {
            [self configureView];
        }
        
        
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)configureView {
    // Update the user interface for the detail item.
    /* Add Grey Screen if no detail item exists*/
//    if (!self.detailItem) {
//        
//        UIView *greyView = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,self.view.bounds.origin.y, self.view.bounds.size.height,self.view.bounds.size.width)];
//        greyView.backgroundColor = [UIColor lightGrayColor];
//        greyView.alpha = 0.5;
//        
//        CGFloat labelX = self.view.bounds.size.width - 400;
//        
//        
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(labelX, 180, 300, 60)];
//        label.backgroundColor = [UIColor grayColor];
//        label.text = @"PLease select a note from the menu \n or hit the + to create a new one";
//        label.numberOfLines = 2;
//        label.textAlignment = UITextAlignmentCenter;
//        [label.layer setCornerRadius:10];
//        label.layer.masksToBounds = YES;
//        
//        
//        [greyView addSubview:label];
//        
//        
//        
//        
//        
//        [self.view addSubview:greyView];
//        
//    }
    
    
    if (self.detailItem) {
        self.titleTextField.text = [[self.detailItem valueForKey:@"title"] description];
        self.textView.text = [[self.detailItem valueForKey:@"text"] description];
    }
    
    self.textView.delegate = self;
    if ([self.textView.text isEqualToString:@""]) {
    self.textView.text = @"Add note here";
    self.textView.textColor = [UIColor lightGrayColor];
    }
//    self.textView.dataDetectorTypes = UIDataDetectorTypeAll;
    
    self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryOverlay;
    
    // Recreate toolbar as it doesn't show in SizeClassRegular

    if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular || self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular) {

        UINavigationBar *naviBar = [[UINavigationBar alloc] init];
        UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@"bNotes Detail"];
        UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveNote:)];
        UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareButton:)];
        NSArray *buttonArray = @[save, share];
        
        item.rightBarButtonItems = buttonArray;
        
        [naviBar pushNavigationItem:item animated:NO];
    
        [self.view addSubview:naviBar];
        
        naviBar.translatesAutoresizingMaskIntoConstraints = NO;
        self.textView.translatesAutoresizingMaskIntoConstraints = NO;
        self.titleTextField.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.view removeConstraints:[self.view constraints]];
        
        NSLayoutConstraint *naviWidthConstraint = [NSLayoutConstraint constraintWithItem:naviBar
                                                                               attribute:NSLayoutAttributeWidth
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self.view
                                                                               attribute:NSLayoutAttributeWidth
                                                                              multiplier:1
                                                                                constant:0];
        NSLayoutConstraint *naviTopConstraint = [NSLayoutConstraint constraintWithItem:naviBar
                                                                             attribute:NSLayoutAttributeTop
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self.view
                                                                             attribute:NSLayoutAttributeTop
                                                                            multiplier:1
                                                                              constant:20];
        NSLayoutConstraint *titleWidthConstaint = [NSLayoutConstraint constraintWithItem:_titleTextField
                                                                             attribute:NSLayoutAttributeWidth
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self.view
                                                                             attribute:NSLayoutAttributeWidth
                                                                            multiplier:1
                                                                              constant:0];
        NSLayoutConstraint *titleTopConstraint = [NSLayoutConstraint constraintWithItem:_titleTextField
                                                                             attribute:NSLayoutAttributeTop
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:naviBar
                                                                              attribute:NSLayoutAttributeBottom
                                                                            multiplier:1
                                                                              constant:8];
        NSLayoutConstraint *textFieldWidthConstraint = [NSLayoutConstraint constraintWithItem:_textView
                                                                             attribute:NSLayoutAttributeWidth
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self.view
                                                                             attribute:NSLayoutAttributeWidth
                                                                            multiplier:1
                                                                              constant:0];
        NSLayoutConstraint *textFieldTopConstraint = [NSLayoutConstraint constraintWithItem:_textView
                                                                             attribute:NSLayoutAttributeTop
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:_titleTextField
                                                                             attribute:NSLayoutAttributeBottom
                                                                            multiplier:1
                                                                              constant:8];
        NSLayoutConstraint *textFieldBottomConstraint = [NSLayoutConstraint constraintWithItem:_textView
                                                                             attribute:NSLayoutAttributeBottom
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self.view
                                                                             attribute:NSLayoutAttributeBottomMargin
                                                                            multiplier:1
                                                                              constant:-20];
        NSArray *constraints = @[naviWidthConstraint, naviTopConstraint, titleTopConstraint, titleWidthConstaint, textFieldBottomConstraint, textFieldTopConstraint, textFieldWidthConstraint];
        [self.view addConstraints:constraints];
        
        
        self.iPadViewLaidOut = true;
        
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    
    
    // Update the view.
    if (!self.iPadViewLaidOut) {
        [self configureView];
    }
    
    
}

-(void)viewDidAppear:(BOOL)animated
{
    
    // TODO: Need to have the initial detailItem load up when the view first loads
//    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
//        if (!self.detailItem) {
//            // This is for iPad, as the detail view ends up being the initial view controller presented
//            AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//            self.persistenceController = ad.persistenceController;
//            self.detailItem = [self.fetchedResultsController fetchedObjects][0];
//            
//        }
//    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    if ([self.textView.text isEqual:@"Add note here"] && [self.titleTextField.text isEqual:@""]){
        NSManagedObjectContext *context = [self.persistenceController managedObjectContext];
        [context deleteObject:_detailItem];
        
        [self.persistenceController save];
    } else {
        [_detailItem setValue:self.textView.text forKey:@"text"];
        [_detailItem setValue:self.titleTextField.text forKey:@"title"];
        [self.persistenceController save];
    }
    
   
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([self.textView.text isEqual:@"Add note here"]) {
        [_detailItem setValue:@"" forKey:@"text"];
    } else {
    [_detailItem setValue:self.textView.text forKey:@"text"];
    }
    [_detailItem setValue:self.titleTextField.text forKey:@"title"];
    [self.persistenceController save];
}

//- (IBAction)addButton:(id)sender {
////    [_detailItem setValue:self.textView.text forKey:@"text"];
////    [_detailItem setValue:self.titleTextField.text forKey:@"title"];
////    [self.persistenceController save];
//}
//
- (IBAction)saveNote:(id)sender
{
    [_detailItem setValue:self.textView.text forKey:@"text"];
    [_detailItem setValue:self.titleTextField.text forKey:@"title"];
    [self.persistenceController save];
    
    [self performSegueWithIdentifier:@"unwindSegue" sender:self];
}


- (IBAction)shareButton:(id)sender {
    NSMutableArray *itemsToShare = [NSMutableArray array];
    
    if (self.titleTextField.text > 0) {
        [itemsToShare addObject:self.titleTextField.text];
    }
    
    if (self.textView.text > 0) {
        [itemsToShare addObject:self.textView.text];
    }
    
    if (itemsToShare.count > 0) {
        
        
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
        if ( [activityVC respondsToSelector:@selector(popoverPresentationController)] ) {
            // iOS8
            activityVC.popoverPresentationController.sourceView =
            self.view;
        }
        [self presentViewController:activityVC animated:YES completion:nil];
    }
}

#pragma mark - Text View Delegates

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([self.textView.text isEqualToString:@"Add note here"]) {
        self.textView.text = @"";
        self.textView.textColor = [UIColor blackColor];
    }
    [self.textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([self.textView.text isEqualToString:@""]) {
        self.textView.text = @"Add note here";
        self.textView.textColor = [UIColor lightGrayColor];
    }
}

#pragma mark - Fetched results controller

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
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.persistenceController.managedObjectContext sectionNameKeyPath:nil cacheName:@"AllNotes"];
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


@end
