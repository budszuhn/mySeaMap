//
//  MSMViewController.h
//  mySeaMap
//
//  Created by Frank Budszuhn on 04.11.13.
//  Copyright (c) 2013 Frank Budszuhn. See LICENSE.
//

@import UIKit;

#import "MSMBaseMapViewController.h"

@protocol MSMMapViewDelegate <NSObject>

- (void) setRegion: (MKCoordinateRegion) region;

@end

@interface MSMViewController : MSMBaseMapViewController

@end
