//
//  MSMSettingsViewController.h
//  mySeaMap
//
//  Created by Frank Budszuhn on 04.11.13.
//  Copyright (c) 2013 - 2016 Frank Budszuhn. See LICENSE.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MSMGeoUtils.h"
#import "MSMViewController.h"
#import "MSMMapSource.h"

@protocol MSMSettingsViewControllerDelegate <NSObject>
- (void) showCrosshairs: (BOOL) show;
- (void) showScale: (BOOL) show;
- (void) showBigInstruments: (BOOL) bigInstruments;
- (void) allowRotateAndTilt: (BOOL) allow;

- (void) showUrl: (NSDictionary *) urlInfo;
- (void) measurementSystemChanged: (BOOL) isMetric;

@end


@interface MSMSettingsViewController : UITableViewController <UIPopoverPresentationControllerDelegate>

@property (nonatomic, weak) id <MSMSettingsViewControllerDelegate> delegate;
@property (weak, nonatomic) id <MSMMapViewDelegate> mapViewDelegate;


@end
