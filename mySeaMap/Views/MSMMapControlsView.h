//
//  MSMMapControlsView.h
//  mySeaMap
//
//  Created by Frank Budszuhn on 05.11.13.
//  Copyright (c) 2013 - 2016 Frank Budszuhn. See LICENSE.
//

#import <UIKit/UIKit.h>

@interface MSMMapControlsView : UIView

@property (nonatomic, strong) UIColor *drawColor;

@property (nonatomic) BOOL isDrawCrosshairs;

/// Mittelpunkt des Fadenkreuzes (CGPoint) in eigenen Koordinaten; nil = Mitte der View
@property (nonatomic, strong) NSValue *crosshairCenter;


@end
