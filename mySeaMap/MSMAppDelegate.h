//
//  MSMAppDelegate.h
//  mySeaMap
//
//  Created by Frank Budszuhn on 04.11.13.
//  Copyright (c) 2013 Frank Budszuhn. See LICENSE.
//

#import <UIKit/UIKit.h>

@interface MSMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic) CGFloat displayBrightness;
@property (nonatomic) BOOL nightMode;
@property (nonatomic) NSDictionary *externalLaunchParams; 

@end
