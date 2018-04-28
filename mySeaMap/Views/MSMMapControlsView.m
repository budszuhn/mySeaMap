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
    CGFloat centerX = self.bounds.size.width / 2.0;
    CGFloat centerY = self.bounds.size.height / 2.0 + [MSMUtils statusBarOffsetForRead: NO]; // Schade, aber wir brauchen diesen Offset hier. Sonst funktioniert das Centering auf die eigene Position nicht
    
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


-(void)setDrawColor:(UIColor*)value {
    _drawColor = value;
    [self setNeedsDisplay];
}


@end
