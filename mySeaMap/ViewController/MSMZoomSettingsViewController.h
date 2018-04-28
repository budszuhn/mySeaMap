//
//  MSMZoomSettingsViewController.h
//  mySeaMap
//
//  Created by Frank Budszuhn on 13.05.14.
//  Copyright (c) 2014 Frank Budszuhn. See LICENSE.
//

#import <UIKit/UIKit.h>

@protocol MSMZoomSettingsViewControllerDelegate <NSObject>

- (void) setScaleFacor: (double) scaleFactor;
- (void) zoomDone;

@end

@interface MSMZoomSettingsViewController : UITableViewController

@property (weak, nonatomic) id <MSMZoomSettingsViewControllerDelegate> delegate;

@end
