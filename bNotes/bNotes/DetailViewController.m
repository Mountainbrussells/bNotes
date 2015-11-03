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

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
    
    [self.persistenceController save];
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [_detailItem setValue:self.textView.text forKey:@"text"];
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


@end
