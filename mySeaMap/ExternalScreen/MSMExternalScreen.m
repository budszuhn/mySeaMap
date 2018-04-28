//
//  MSMExternalScreen.m
//  mySeaMap
//
//  Created by Frank Budszuhn on 18.06.14.
//  Copyright (c) 2014 - 2016 Frank Budszuhn. See LICENSE.
//

#import "MSMFeatureManager.h"
#import "MSMExternalScreen.h"
#import "MSMExternalScreenMapViewController.h"

@interface MSMExternalScreen ()


@end

@implementation MSMExternalScreen

+ (void) start
{
    if ([MSMFeatureManager hasFeature: MSMFeatureExternalDisplay])
    {
        NSArray *screens = [UIScreen screens];
        
        NSLog(@"screens = %@", screens);
        
        for (UIScreen *aScreen in screens)
        {
            if (! [aScreen isEqual:[UIScreen mainScreen]])
            {
                [[MSMExternalScreen sharedInstance] setupExternalScreen: aScreen];
                return;
            }
        }
    }
}

+ (MSMExternalScreen *) sharedInstance
{
    static dispatch_once_t once;
    static MSMExternalScreen *_sharedInstance;
    dispatch_once(&once, ^ { _sharedInstance = [[self alloc] init]; });
    return _sharedInstance;
}


- (void) setupExternalScreen: (UIScreen *) screen
{
    NSLog(@"Found external Screen: %@", screen);
    
    for (UIScreenMode *aMode in [screen availableModes])
    {
        NSLog(@"## a mode = %@", aMode);
    }

    UIWindow *window = [[UIWindow alloc] initWithFrame:[screen bounds]];
    self.window = window;

    window.screen = screen;
    
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ExternalScreen" bundle:nil];
    self.window.rootViewController = [storyboard instantiateInitialViewController];
    [self.window makeKeyAndVisible];
}

- (void) setRegion: (MKCoordinateRegion) region
{
    MSMExternalScreenMapViewController *vc = (MSMExternalScreenMapViewController *) self.window.rootViewController;
    [vc setRegion: region];
}


@end
