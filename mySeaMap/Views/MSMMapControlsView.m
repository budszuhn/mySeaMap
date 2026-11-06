//
//  MSMMapControlsView.m
//  mySeaMap
//
//  Created by Frank Budszuhn on 05.11.13.
//  Copyright (c) 2013 - 2016 Frank Budszuhn. See LICENSE.
//

#import "MSMMapControlsView.h"
#import "MSMUtils.h"

@interface MSMMapControlsView ()


@end

@implementation MSMMapControlsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder: aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}


- (void) setup
{
    _isDrawCrosshairs = [MSMUtils userDefaultForKey: USER_DEFAULTS_CROSSHAIRS];    
}


- (void)drawRect:(CGRect)rect
{
    if (_isDrawCrosshairs) {
        [self drawCrosshairs];
    }
    
}


- (void) drawCrosshairs
{
    CGSize crossHairSize = CGSizeMake(44, 44);
    // Mittelpunkt wird vom MSMViewController aus der tatsächlichen Kartenmitte berechnet
    // (früher: feste Statusleisten-Korrektur, die auf iPhones mit Notch / Dynamic Island nicht stimmte)
    CGPoint center = self.crosshairCenter ? [self.crosshairCenter CGPointValue] : CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGFloat centerX = center.x;
    CGFloat centerY = center.y;
    
    CGRect calculatedCrossHairRect = CGRectMake(centerX-(crossHairSize.width/2),
                                                centerY-(crossHairSize.width/2),
                                                crossHairSize.width,
                                                crossHairSize.height);
    
    [StyleKit drawCrossHairWithFrame:calculatedCrossHairRect crossHairStrokeColor:self.drawColor crossHairStrokeWidth:0.75];
}


-(void)setIsDrawCrosshairs:(BOOL)value {
    _isDrawCrosshairs = value;
    [self setNeedsDisplay];
}


-(void)setCrosshairCenter:(NSValue *)value {
    // isEqualToValue: darf nicht mit nil aufgerufen werden (Absturz beim ersten Aufruf)
    if (value == _crosshairCenter || (value != nil && _crosshairCenter != nil && [value isEqualToValue: _crosshairCenter]))
        return;
    _crosshairCenter = value;
    [self setNeedsDisplay];
}


-(void)setDrawColor:(UIColor*)value {
    _drawColor = value;
    [self setNeedsDisplay];
}


@end
