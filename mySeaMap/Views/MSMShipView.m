//
//  MSMShipView.m
//  mySeaMap
//
//  Created by Frank Budszuhn on 17.04.14.
//  Copyright (c) 2014 - 2016 Frank Budszuhn. See LICENSE.
//

#import "MSMShipView.h"
#import "MSMLocationManager.h"

@implementation MSMShipView

- (void)drawRect:(CGRect)rect
{
    MSMLocationManager *locationManager = (MSMLocationManager *) self.annotation;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);

    
    CGContextSetLineWidth(context, 3.0);
    
    [[UIColor colorWithRed:20.0/255.0 green:98.0/255.0 blue:249.0/255.0 alpha:1.0] setFill];
    [[UIColor whiteColor] setStroke];
    
    CGFloat centerX = self.frame.size.width / 2.0 - self.centerOffset.x;
    CGFloat centerY = self.frame.size.height / 2.0 - self.centerOffset.y;

    // Schiff drehen entsprechend des Kurses (Spitze zeigt nach vorne)
    if (self.mapTrackingType != MSMMapTrackingTypeHeading)
    {
        CGContextTranslateCTM(context, centerX, centerY);
        CGContextRotateCTM(context, radians(locationManager.currentLocation.course - self.cameraHeading));
        CGContextTranslateCTM(context, -centerX, -centerY);
    }

    // das Schiff:
    CGContextMoveToPoint(context, centerX-5.0, centerY+10.0);
    CGContextAddLineToPoint(context, centerX+5.0, centerY+10.0);
    CGContextAddQuadCurveToPoint(context, centerX+10.0, centerY, centerX, centerY-20.0);
    CGContextAddQuadCurveToPoint(context, centerX-10.0, centerY, centerX-5.0, centerY+10.0);
    CGContextAddLineToPoint(context, centerX, centerY+10.0); // sonst sieht die Backboard-Ecke am Heck doof aus
    CGContextDrawPath(context, kCGPathFillStroke);

    CGContextRestoreGState(context);
}

// helper
static inline float radians(double degrees) { return degrees * M_PI / 180; }


@end
