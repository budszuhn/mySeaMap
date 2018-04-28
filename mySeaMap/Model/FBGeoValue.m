//
//  FBGeoValue.m
//  mySeaMap
//
//  Created by Frank Budszuhn on 08.11.13.
//  Copyright (c) 2013 Frank Budszuhn. See LICENSE.
//

#import "FBGeoValue.h"

@interface FBGeoValue ()

@end

@implementation FBGeoValue



// konvertiert aus Java (FBBase)
- (void) calcPrivateParts
{
    _sign = _locationDegrees < 0 ? -1 : 1;
    
    _degrees = fabs( _locationDegrees );
    _minutes = 60.0 * (fabs(_locationDegrees) - _degrees);
    
    // dies ist für eine Anzeigegenauigkeit von zwei Nachkommastellen bei den Minuten gedacht
    if (_minutes > 59.994)
    {
        _degrees++;
        _minutes = 0.0;
    }
}


- (NSString *) description
{
    return [NSString stringWithFormat:@"%d°%f'", _sign*_degrees, _minutes];
}


// accessors


- (void) setLocationDegrees:(CLLocationDegrees)locationDegrees
{
    _locationDegrees = locationDegrees;
    
    [self calcPrivateParts];
}


@end
