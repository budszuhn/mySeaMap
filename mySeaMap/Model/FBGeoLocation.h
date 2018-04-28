//
//  FBGeoLocation.h
//  mySeaMap
//
//  Created by Frank Budszuhn on 08.11.13.
//  Copyright (c) 2013 - 2016 Frank Budszuhn. See LICENSE.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface FBGeoLocation : NSObject

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic) CLLocationDirection course;
@property (nonatomic) CLLocationSpeed speed;
@property (nonatomic) CLLocationAccuracy accuracy;
@property (nonatomic, strong) NSDate *timestamp;

+ (FBGeoLocation *) withLocation: (CLLocation *) location;
+ (FBGeoLocation *) fromDict: (NSDictionary *) dict;

// have it as CLLocation
- (CLLocation *) location;

- (BOOL) hasValidCourseInfo;
- (NSString *) nauticalDescription;

- (NSString *) formattedLatitude;
- (NSString *) formattedLongitude;
- (NSString *) formattedCourse;
- (NSString *) formattedSpeed;

// so kann es in einer plist gespeichert werden
- (NSDictionary *) dictRepresentation;

// für copy/paste
- (NSString *) pasteboardRepresentation;

@end
