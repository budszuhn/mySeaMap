//
//  MSMExternalScreenMapViewController.m
//  mySeaMap
//
//  Created by Frank Budszuhn on 19.06.14.
//  Copyright (c) 2014 - 2016 Frank Budszuhn. See LICENSE.
//

#import "MSMExternalScreenMapViewController.h"
#import "FBGeoLocation.h"
#import "MSMUtils.h"

// Automatischer Import für Swift
#import "myseamap-Swift.h"

@interface MSMExternalScreenMapViewController ()

@property (weak, nonatomic) IBOutlet MSMScaleView *scaleView;
@property (weak, nonatomic) IBOutlet UILabel *scaleLabel;

@end

@implementation MSMExternalScreenMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    MSMMapSource *mapSource = [MSMMapSource mapSourceFromUserDefaults];

    self.scaleLabel.textColor = [mapSource controllsDrawColour];
    self.scaleView.hidden = ![MSMUtils userDefaultForKey: USER_DEFAULTS_SCALE];

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(notifyMapSourceChanged:)
                                                 name: NOTIFICATION_MAP_SOURCE_CHANGED
                                               object: nil];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}



- (void) setRegion: (MKCoordinateRegion) region
{
    [self.mapView setRegion: region animated:YES];
    
}

- (void) notifyMapSourceChanged: (NSNotification *) notification
{
    MSMMapSource *mapSource = notification.userInfo[@"mapSource"];
    self.scaleLabel.textColor = [mapSource controllsDrawColour];
    [self setMapSource: mapSource];
}


#pragma mark - MapView delegate

- (void) mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    NSLog(@"##### external Screen - region did change");
}

@end
