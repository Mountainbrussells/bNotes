//
//  DetailViewController.h
//  bNotes
//
//  Created by Ben Russell on 10/28/15.
//  Copyright © 2015 Ben Russell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersistenceController.h"

@interface DetailViewController : UIViewController<NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) PersistenceController *persistenceController;


@end

