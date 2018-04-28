//
//  MSMSearchViewController.h
//  mySeaMap
//
//  Created by Frank Budszuhn on 15.03.14.
//  Copyright (c) 2014 Frank Budszuhn. See LICENSE.
//

#import <UIKit/UIKit.h>

@protocol MSMSearchViewControllerDelegate <NSObject>
- (void) searchDone;
- (void) setPlacemark: (CLPlacemark *) placemark;
@end


@interface MSMSearchViewController : UIViewController

@property (weak, nonatomic) id <MSMSearchViewControllerDelegate> delegate;

@end
