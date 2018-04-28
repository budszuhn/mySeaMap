//
//  FBGeoLocation.m
//  mySeaMap
//
//  Created by Frank Budszuhn on 08.11.13.
//  Copyright (c) 2013 Frank Budszuhn. See LICENSE.
//

#import "FBGeoLocation.h"
#import "FBGeoValue.h"
#import "MSMUtils.h"


@interface FBGeoLocation ()

@property (nonatomic, strong) FBGeoValue *latitude;
@property (nonatomic, strong) FBGeoValue *longitude;

@end

@implementation FBGeoLocation

+ (FBGeoLocation *) withLocation: (CLLocation *) location
{
    FBGeoLocation *loc = [[FBGeoLocation alloc] init];    
    loc.coordinate = location.coordinate;
    loc.course = location.course;
    loc.speed = location.speed;
    loc.accuracy = location.horizontalAccuracy;
    loc.timestamp = [NSDate date];
    
    return loc;
}

+ (FBGeoLocation *) fromDict: (NSDictionary *) dict
{
    FBGeoLocation *loc = [[FBGeoLocation alloc] init];
    CLLocationDegrees latitude = [[dict valueForKey: @"latitude"] doubleValue];
    CLLocationDegrees longitude = [[dict valueForKey: @"longitude"] doubleValue];
    loc.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    loc.course = [[dict valueForKey: @"course"] doubleValue];
    loc.speed = [[dict valueForKey: @"speed"] doubleValue];;
    loc.accuracy = [[dict valueForKey: @"accuracy"] doubleValue];;
    loc.timestamp = [dict valueForKey: @"timestamp"];
    
    return loc;
}

- (CLLocation *) location
{
    return [[CLLocation alloc] initWithLatitude:self.latitude.locationDegrees longitude:self.longitude.locationDegrees];
}


- (BOOL) hasValidCourseInfo
{
    return self.course > -1.0 && self.speed > .5; // wir erachten erst .5 m/s als 'sinnvolle' Geschwindigkeit
}

- (NSString *) nauticalDescription
{
    return [NSString stringWithFormat:@"%@, %@", [self formattedLatitude], [self formattedLongitude]];
}

- (NSString *) formattedLatitude
{
    NSString *latStr = self.latitude.sign < 0 ? @"S" : @"N";
    return [NSString stringWithFormat:@"%02ld°%05.2f'%@", (long)self.latitude.degrees, self.latitude.minutes, latStr];
}

- (NSString *) formattedLongitude
{
    NSString *lngStr = self.longitude.sign < 0 ? @"W" : @"E";
    return [NSString stringWithFormat:@"%03ld°%05.2f'%@", (long)self.longitude.degrees, self.longitude.minutes, lngStr];
}

- (NSString *) formattedCourse
{
    if ([self hasValidCourseInfo])
    {
        return [NSString stringWithFormat:@"%03.0f°", self.course];
    }
    else
    {
        return @"---";
    }
}

- (NSString *) formattedSpeed
{
    if ([self hasValidCourseInfo])
    {
        BOOL isMetric = [MSMUtils userDefaultForKey:USER_DEFAULTS_UNITS_METRIC withDefault: NO];
        
        if (isMetric) {
            return [NSString stringWithFormat:@"%2.1f km/h", self.speed * 3.6]; // input ist m/s
        }
        else {
            return [NSString stringWithFormat:@"%2.1f kn", self.speed * 1.94385]; // input ist m/s
        }
    }
    else
    {
        return @"---";
    }
}


- (NSDictionary *) dictRepresentation
{
    return @{@"latitude": [NSNumber numberWithDouble: self.latitude.locationDegrees],
             @"longitude": [NSNumber numberWithDouble: self.longitude.locationDegrees],
             @"speed": [NSNumber numberWithDouble: self.speed],
             @"course": [NSNumber numberWithDouble: self.course],
             @"accuracy": [NSNumber numberWithDouble: self.accuracy],
             @"timestamp": self.timestamp};
}

- (NSString *) pasteboardRepresentation
{
    return [NSString stringWithFormat:@"%f,%f", self.latitude.locationDegrees, self.longitude.locationDegrees];
}


// accessors

- (CLLocationCoordinate2D) coordinate
{
    return CLLocationCoordinate2DMake(_latitude.locationDegrees, _longitude.locationDegrees);
}

- (void) setCoordinate:(CLLocationCoordinate2D)coordinate
{
    self.longitude = [[FBGeoValue alloc] init]; self.longitude.locationDegrees = coordinate.longitude;
    self.latitude = [[FBGeoValue alloc] init]; self.latitude.locationDegrees = coordinate.latitude;
}

// debug

- (NSString *) description
{
    return [[self dictRepresentation] description];
}

@end
