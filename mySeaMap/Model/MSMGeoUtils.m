//
//  MSMGeoUtils.m
//  mySeaMap
//
//  Created by Frank Budszuhn on 11.11.13.
//  Copyright (c) 2013 - 2016 Frank Budszuhn. See LICENSE.
//
//  Hier eine wichtige Quelle: http://www.movable-type.co.uk/scripts/latlong.html


#import "MSMGeoUtils.h"
#import "MSMUtils.h"

@implementation MSMGeoUtils

// soll mit Seemeilen aufgerufen werden und Seemeilen liefern
// 25.7.16 oder alternativ mit Kilometern. Das funktioniert so ohne Änderung.
+ (double) scaleWidthForMapWidth: (double) mapWidth inOrientation: (UIInterfaceOrientation) orientation
{
    double result;
    
    if ([MSMUtils isIPad])
        result = mapWidth / 6.0;
    else if (UIInterfaceOrientationIsLandscape(orientation))
        result = mapWidth / 3.0;
    else
        result = mapWidth / 2.0; // bei iPhone Portrait passt sonst die Schrift nicht
    
    return [self userFriendlyValue: result];
}

// Skala soll in ein 1/2/5-Schema gepresst werden
+ (double) userFriendlyValue: (double) value
{
    double logVal = log10(value);
    double exponent = logVal >= 0 ? trunc(logVal) : trunc(logVal) - 1.0;
    double d = pow(10.0, exponent);
    double nv = [self nextLogValue: value / d];
    
    return nv * d;
}


// gibt den nächstkleineren Wert aus einer 1/2/5-Reihe zurück
+ (double) nextLogValue: (double) value
{
    NSAssert(value >= 1.0, @"Value muss größer 1 sein");
    NSAssert(value < 10.0, @"Value muss kleiner 10 sein");
    
    if (value > 5.0)
        return 5.0;
    else if (value > 2.0)
        return 2.0;
    else
        return 1.0;
}

// guckst Du hier:
// http://stackoverflow.com/questions/3809337/calculating-bearing-between-two-cllocationcoordinate2ds

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiandsToDegrees(x) (x * 180.0 / M_PI)

+ (float)getHeadingForDirectionFromCoordinate:(CLLocationCoordinate2D)fromLoc toCoordinate:(CLLocationCoordinate2D)toLoc
{
    float fLat = degreesToRadians(fromLoc.latitude);
    float fLng = degreesToRadians(fromLoc.longitude);
    float tLat = degreesToRadians(toLoc.latitude);
    float tLng = degreesToRadians(toLoc.longitude);
    
    float degree = radiandsToDegrees(atan2(sin(tLng-fLng)*cos(tLat), cos(fLat)*sin(tLat)-sin(fLat)*cos(tLat)*cos(tLng-fLng)));
    
    if (degree >= 0) {
        return degree;
    } else {
        return 360+degree;
    }
}


// TODO: ggf. hier eigene Implementierung bauen
+ (CLLocationDistance) distanceFrom: (CLLocationCoordinate2D) fromLocation to: (CLLocationCoordinate2D) toLocation
{
    CLLocation *l1 = [[CLLocation alloc] initWithLatitude:fromLocation.latitude longitude:fromLocation.longitude];
    CLLocation *l2 = [[CLLocation alloc] initWithLatitude:toLocation.latitude longitude:toLocation.longitude];
    
    return [l1 distanceFromLocation: l2];
}



// http://www.movable-type.co.uk/scripts/latlong.html
//
// neue Position aus Anfangsposition, Kurs und Entfernung (in Metern)
+ (CLLocationCoordinate2D) destinationForStart: (CLLocationCoordinate2D) start distance: (CLLocationDistance) distance bearing: (CLLocationDirection) bearing
{
    double fLat = degreesToRadians(start.latitude);
    double fLon = degreesToRadians(start.longitude);
    double fBearing = degreesToRadians(bearing);
    double fDistance = distance / 6371000;
    
    double lat =  asin( sin(fLat)*cos(fDistance) + cos(fLat)*sin(fDistance)*cos(fBearing) );
    double lon = fLon + atan2( sin(fBearing)*sin(fDistance)*cos(fLat), cos(fDistance) - sin(fLat)*sin(lat) );
    
    return CLLocationCoordinate2DMake(radiandsToDegrees(lat), radiandsToDegrees(lon));
}

+ (void) reverseGeocodeLocation: (CLLocationCoordinate2D) location
                        success: (void (^)(NSString *locationDescription))success
                        failure: (void (^)(NSError *error)) failure
{
    CLGeocoder *gc = [[CLGeocoder alloc] init];
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];
    [gc reverseGeocodeLocation:loc completionHandler:^(NSArray *placemarks, NSError *error) {
        
        CLPlacemark *pl = [placemarks firstObject];
        
        if (pl)
        {
            NSString *result = nil;
            if (pl.subLocality)
            {
                result = pl.subLocality;
            }
            else if (pl.locality)
            {
                result = pl.locality;
            }
            else if (pl.inlandWater)
            {
                result = pl.inlandWater;
            }
            else if (pl.ocean)
            {
                result = pl.ocean;
            }
            else if (pl.name) // Name ist meist nicht so dolle, nehmen es als letzen Fallback
            {
                result = pl.name;
            }
                        
            success(result);
        }
        else
        {
            if (failure)
            {
                failure(error);
            }
        }
    }];
}



@end
