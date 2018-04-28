//
//  MSMShipView.h
//  mySeaMap
//
//  Created by Frank Budszuhn on 17.04.14.
//  Copyright (c) 2014 Frank Budszuhn. See LICENSE.
//

#import <UIKit/UIKit.h>
#import "MSMGlobalDefines.h"

@interface MSMShipView : MKAnnotationView

@property (nonatomic) CGFloat mapScaleFactor; // Anzahl Meter mal diesem Faktor gibt die notwendige Anzahl von Punkten im View
@property (nonatomic) MSMMapTrackingType mapTrackingType;
@property (nonatomic) CLLocationDirection cameraHeading;

@end
