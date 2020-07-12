//
//  MSMSearchViewController.h
//  mySeaMap
//
//  Created by Frank Budszuhn on 15.03.14.
//  Copyright (c) 2014 - 2020 Frank Budszuhn. See LICENSE.
//

#import <UIKit/UIKit.h>

@protocol MSMSearchViewControllerDelegate <NSObject>
- (void) searchDone;
- (void) setPlacemark: (CLPlacemark *) placemark;
@end

