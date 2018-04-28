//
//  MSMBaseMapViewController.h
//  mySeaMap
//
//  Created by Frank Budszuhn on 19.06.14.
//  Copyright (c) 2014 Frank Budszuhn. See LICENSE.
//

#import <UIKit/UIKit.h>
#import "MSMMapSource.h"
#import "MSMShipView.h"

@interface MSMBaseMapViewController : UIViewController

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) MSMShipView *shipView;
@property (nonatomic) MSMMapTrackingType mapTrackingType;

@property (strong, nonatomic) MKPolyline *trackingLine;

- (void) loadMapState;
- (void) setMapSource: (MSMMapSource *) mapSource;

- (void) updateShipPosition;


@end
