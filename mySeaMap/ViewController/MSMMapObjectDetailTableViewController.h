//
//  MSMMapObjectDetailTableViewController.h
//  mySeaMap
//
//  Created by Frank Budszuhn on 16.03.14.
//  Copyright (c) 2014 Frank Budszuhn. See LICENSE.
//

#import <UIKit/UIKit.h>
#import "MSMMapObject.h"

@protocol MSMMapObjectsViewControllerDelegate <NSObject>

- (void) showUrl: (NSDictionary *) urlInfo;

@end


@interface MSMMapObjectDetailTableViewController : UITableViewController <UIPopoverPresentationControllerDelegate>

@property (strong, nonatomic) MSMMapObject *mapObject;
@property (weak, nonatomic) id <MSMMapObjectsViewControllerDelegate> delegate;

@end
