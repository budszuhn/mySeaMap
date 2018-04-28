//
//  MSMLocationManager.m
//  mySeaMap
//
//  Created by Frank Budszuhn on 20.12.13.
//  Copyright (c) 2013 - 2017 Frank Budszuhn. See LICENSE.
//

#import "MSMLocationManager.h"
#import "MSMUtils.h"

@interface MSMLocationManager () <CLLocationManagerDelegate>

// Core Location
@property (strong, nonatomic) CLLocationManager *locationManager;

// fb, 15.6.2016 - irgendetwas hat sich am KVO und Maps geändert. Jedenfalls geht es, wenn wir die Koordinate in eine Property tun.
@property (nonatomic) CLLocationCoordinate2D coordinate;


@end

@implementation MSMLocationManager

+ (MSMLocationManager *) manager {
    static MSMLocationManager *_sharedManager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedManager = [[self alloc] init];
    });
    return _sharedManager;
}

- (instancetype) init
{
    self = [super init];
    if (self)
    {
        [self startLocationManager];
    }
    
    return self;
}



#pragma mark - CoreLocation

- (void) startLocationManager
{
    if (CLLocationManager.locationServicesEnabled) {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        
        if (status != kCLAuthorizationStatusDenied && status != kCLAuthorizationStatusRestricted) {
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.delegate = self;
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            self.locationManager.activityType = CLActivityTypeOtherNavigation; // Apple nennt hier ausdrücklich 'boats' !!!
            self.locationManager.allowsBackgroundLocationUpdates = NO; // wird erst mit dem Tracking eingeschaltet
            //self.locationManager.distanceFilter = 10; ## fb, 4.8.17 - mal sehen, ob er dann weniger 'hängen' bleibt -- fb, 13.8.17, JA, das ist so!!!
            
            if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
                [self.locationManager startUpdatingLocation];
            }
            else if (status == kCLAuthorizationStatusNotDetermined ) { // fb, 13.8.17 - wir nehmen jetzt wieder "whenInUse"
                [self.locationManager requestWhenInUseAuthorization]; 
            }
        }

        _available = (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse);
    }
    else {
        _available = NO;
    }
}

- (void) stopLocationManager
{
    [self.locationManager stopUpdatingLocation];
}


#pragma mark - Background Tracking

// wenn wir nicht tracken, dann schalten wir das ab
// TODO: seltsamerweise lässt es sich einmal einschalten, aber dann nicht wieder abschalten. Wie seltsam.
// vielleicht müssen wir die updates stoppen, wenn wir nicht tracken und in den Hintergrund gehen?
- (void) setAllowsBackgroundUpdates: (BOOL) on {
    // fb, 13.8.17 - das kommentieren wir vorsichtshalber mal aus
    //self.locationManager.allowsBackgroundLocationUpdates = on;
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
#if !MSM_DEMO_MODE
    CLLocation *loc = [locations lastObject];
    FBGeoLocation *location = [FBGeoLocation withLocation: loc];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_POSITION_CHANGED object:self userInfo:@{@"loc": location}];
    
    self.coordinate = loc.coordinate;
#endif
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"### did fail with error: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"### did change auth status");
    _available = CLLocationManager.locationServicesEnabled && (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways);
    if (_available) {
        [self.locationManager startUpdatingLocation];
    }
        
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOCATION_MANAGER_CHANGE object:self userInfo:nil];
}



#pragma mark - Getter / Setter


- (FBGeoLocation *) currentLocation
{
#if MSM_DEMO_MODE
    // schön auf der Elbe vor Altengamme
    NSDictionary *demoLocDict = @{@"latitude" : @"53.4313",
                                  @"longitude" : @"10.3",
                                  @"speed" : @"2.8",
                                  @"course" : @"240.2",
                                  @"accuracy" : @"50",
                                  @"timestamp" : @"2016-12-13 06:36:11.280"
                                  };
    FBGeoLocation *loc = [FBGeoLocation fromDict:demoLocDict];
    
    self.coordinate = loc.coordinate; // damit auch unser Schiffchen gezeigt wird
    
    return loc;
#else
    if (self.locationManager.location)
    {
        return [FBGeoLocation withLocation: self.locationManager.location];
    }
    else
    {
        return nil;
    }
#endif
}


- (NSString *) title
{
    return [self shipName];
}

- (NSString *) shipName
{
    NSString *name = [[NSUserDefaults standardUserDefaults] valueForKey: USER_DEFAULTS_SHIP_NAME];
    if (! name)
    {
        name = NSLocalizedString(@"MY_VESSEL", nil);
        [[NSUserDefaults standardUserDefaults] setValue: name forKey: USER_DEFAULTS_SHIP_NAME];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return name;
}

/* TODO: noch nicht
- (NSString *) subtitle
{
    return @"ist hier";
} */


@end
