//
//  MSMAppDelegate.m
//  mySeaMap
//
//  Created by Frank Budszuhn on 04.11.13.
//  Copyright (c) 2013 - 2016 Frank Budszuhn. See LICENSE.
//

#import <TMCache/TMCache.h>
#import "MSMAppDelegate.h"
#import "MSMLocationManager.h"
#import "MSMUtils.h"
#import "MSMExternalScreen.h"

@implementation MSMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Magical Record
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"myseamap.db"];
    
    [MSMLocationManager manager]; // get it started
    
    application.idleTimerDisabled = YES; // das verhindert den Sleep-Modus
    
    self.nightMode = NO; // muss vom User nach jedem Start wieder neu gesetzt werden. Sinnvoll?
    self.externalLaunchParams = nil;
        
    // external Displays
    [MSMExternalScreen start];
    
    // Setze proportionalen Font für die BarButton-Items, damit die Positionsanzeige nicht "springt"
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont monospacedDigitSystemFontOfSize:16 weight:UIFontWeightRegular]};
    [[UIBarButtonItem appearance] setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    // TODO: hier auch MagicalRecord-Cleanup??
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [MagicalRecord cleanUp];
}

- (BOOL) application:(UIApplication *)app openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<NSString *,id> *)options
{
    if ([@"myseamap" isEqualToString:[url scheme]])
    {
        if ([[url host] isEqualToString:@"getvalues"]) {

            NSString *query = [url query];
            NSLog(@"query = %@", query);
            
            
            NSString *suffix = [query hasSuffix:@"="] ? @"=" : @"";
            NSArray *queryParts = [query componentsSeparatedByString:@"="];
            if ([queryParts count] >= 2 && [[queryParts firstObject] isEqualToString:@"launchurl"])
            {
                NSString *launchUrl = [[queryParts objectAtIndex:1] stringByAppendingString: suffix];
                NSLog(@"launchurl = %@", launchUrl);

                
                MSMLocationManager *locMan = [MSMLocationManager manager];
                FBGeoLocation *loc = [locMan currentLocation];
                
                // wann launchen wir den Weg zurück???
                NSString *callbackUrl = [launchUrl stringByAppendingString: [self generateCallbackParamsForLocation:loc]];
                NSLog(@"callackUrl = %@", callbackUrl);
                return [app openURL: [NSURL URLWithString: callbackUrl]];
            }
        }
        
        
        else { // Behandlung der bisherigen URLs
            NSArray *queryComponents = [[url query] componentsSeparatedByString:@";"];
            NSMutableDictionary *queryDict = [NSMutableDictionary dictionary];
            for (NSString *aPair in queryComponents) {
                NSArray *values = [aPair componentsSeparatedByString:@"="];
                NSString *key = [values objectAtIndex: 0];
                NSString *value = [values objectAtIndex:1];
                if ([self validateLaunchParamKey:key andValue:value]) {
                    [queryDict setObject:value forKey:key];
                }
            }
            
            self.externalLaunchParams = [queryDict copy];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_OPEN_URL object:self userInfo:nil];
        }
    }
    
    return YES;
}

- (NSString *) generateCallbackParamsForLocation: (FBGeoLocation *) location
{
    CLLocationCoordinate2D coordinate = location.coordinate;
    return [NSString stringWithFormat:@"LAT=%f;LON=%f;COG=%f;SOG=%f;ACC=%f", coordinate.latitude, coordinate.longitude, location.course, location.speed, location.accuracy];
}

// damit uns hier keiner Mist unterschiebt
- (BOOL) validateLaunchParamKey: (NSString *) key andValue: (NSString *) value
{
    if ([key isEqualToString:@"lat"]) {
        double lat = [value doubleValue];
        return lat >= -90.0 && lat <= 90.0;
    }
    else if ([key isEqualToString:@"lon"]) {
        double lon = [value doubleValue];
        return lon > -180.0 && lon <= 180.0;
    }
    else if ([key isEqualToString:@"zoom"]) {
        int zoom = [value intValue];
        return zoom > 0 && zoom <= 18;
    }
    else if ([key isEqualToString:@"type"]) {
        int type = [value intValue];
        return type >= 0 && type < 5;
    }
    else if ([key isEqualToString:@"pin"]) {
        return YES;
    }
    
    // TODO: -
    return NO;
}

@end
