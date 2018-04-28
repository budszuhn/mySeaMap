//
//  MSMExternalScreen.h
//  mySeaMap
//
//  Created by Frank Budszuhn on 18.06.14.
//  Copyright (c) 2014 Frank Budszuhn. See LICENSE.
//

@import UIKit;


@interface MSMExternalScreen : NSObject

@property (strong, nonatomic) UIWindow *window;

+ (void) start;
+ (MSMExternalScreen *) sharedInstance;

- (void) setRegion: (MKCoordinateRegion) region;

@end
