//
//  DetailViewController.m
//  bNotes
//
//  Created by Ben Russell on 10/28/15.
//  Copyright © 2015 Ben Russell. All rights reserved.
//

#import "DetailViewController.h"
#import "AppDelegate.h"

@interface DetailViewController ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
            
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
    
    if (self.detailItem) {
        self.titleTextField.text = [[self.detailItem valueForKey:@"title"] description];
        self.textView.text = [[self.detailItem valueForKey:@"text"] description];
    }
    
    self.textView.delegate = self;
    if ([self.textView.text isEqualToString:@""]) {
    self.textView.text = @"Add note here";
    self.textView.textColor = [UIColor lightGrayColor];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_detailItem setValue:self.textView.text forKey:@"text"];
    [_detailItem setValue:self.titleTextField.text forKey:@"title"];
    
    [self saveContext];
    
}

- (void) saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [self.detailItem managedObjectContext];
    
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    
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


@end
