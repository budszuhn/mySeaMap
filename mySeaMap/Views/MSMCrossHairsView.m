//
//  MSMCrossHairsView.m
//  mySeaMap
//
//  Created by Frank Budszuhn on 28.03.14.
//  Copyright (c) 2014 - 2016 Frank Budszuhn. See LICENSE.
//
//  Dieser View wird momentan (21.11.2016) nur in der Toolbar verwendet, nicht auf der Karte

/*
#import "MSMCrossHairsView.h"

@implementation MSMCrossHairsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 0.75);
    
    CGFloat centerX = self.frame.size.width / 2.0;
    CGFloat centerY = self.frame.size.height / 2.0;
    
    CGContextMoveToPoint(context, centerX-13.0, centerY);
    CGContextAddLineToPoint(context, centerX+13.0, centerY);
    CGContextStrokePath(context);
    
    CGContextMoveToPoint(context, centerX, centerY-13.0);
    CGContextAddLineToPoint(context, centerX, centerY+13.0);
    CGContextStrokePath(context);
    
    CGContextAddArc(context, centerX, centerY, 8.0, 0, M_PI*2, 1);
    CGContextStrokePath(context);
}


@end

*/
