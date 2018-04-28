//
//  MSMBaseMapViewController.m
//  mySeaMap
//
//  Created by Frank Budszuhn on 19.06.14.
//  Copyright (c) 2014 Frank Budszuhn. See LICENSE.
//

#import "MSMBaseMapViewController.h"
#import "MSMCachedTileOverlay.h"
#import "MSMLocationManager.h"
#import "MSMGeoUtils.h"

@interface MSMBaseMapViewController ()


@property (strong, nonatomic) MKTileOverlay *baseMapOverlay;
@property (strong, nonatomic) MKTileOverlay *seamarkOverlay;

@property (strong, nonatomic) MKPolyline *headlingLine;

@end

@implementation MSMBaseMapViewController

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

    self.mapView.showsPointsOfInterest = NO;
    self.mapView.showsBuildings = NO;
    
    MSMMapSource *mapSource = [MSMMapSource mapSourceFromUserDefaults];
    [self setMapSource:mapSource];
    self.mapTrackingType = MSMMapTrackingTypeOff;
    
    // Unser Schiff als Annotation
    [self.mapView addAnnotation: [MSMLocationManager manager]];
    
    // Kartenausschnitt aus den User Defaults laden
    [self loadMapState];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadMapState
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    if ([def objectForKey:USER_DEFAULTS_MAP_SPAN_LON])
    {
        MKCoordinateRegion region;
        region.center.latitude = [def doubleForKey: USER_DEFAULTS_MAP_CENTER_LAT];
        region.center.longitude = [def doubleForKey: USER_DEFAULTS_MAP_CENTER_LON];
        region.span.latitudeDelta = [def doubleForKey: USER_DEFAULTS_MAP_SPAN_LAT];
        region.span.longitudeDelta = [def doubleForKey: USER_DEFAULTS_MAP_SPAN_LON];
        
        self.mapView.region = region;
    }
}

- (void) setMapSource: (MSMMapSource *) mapSource
{
    [self removeOverlays];
    
    self.mapView.mapType = [mapSource appleMapType];
    if (mapSource.type != MSMMapSourceTypeApple)
    {
        self.baseMapOverlay = [[MSMCachedTileOverlay alloc] initWithURLTemplate: mapSource.url andCacheName:mapSource.key];
        self.baseMapOverlay.canReplaceMapContent = YES;
        self.baseMapOverlay.geometryFlipped = mapSource.flipped;
        self.baseMapOverlay.minimumZ = 0;
        self.baseMapOverlay.maximumZ = 18; // MapQuest kann auch mehr. Aber leider verschwinden dann die Zeichen im Seamark-Layer, der nur bis 18 kann
        [self.mapView insertOverlay: self.baseMapOverlay belowOverlay: self.trackingLine];
    }
    
    if (mapSource.type != MSMMapSourceTypeStandalone)
    {
        MSMMapSource *seamarkSource = [MSMMapSource seamarks];
        self.seamarkOverlay = [[MSMCachedTileOverlay alloc] initWithURLTemplate:seamarkSource.url andCacheName:seamarkSource.key];
        self.seamarkOverlay.canReplaceMapContent = NO;
        self.seamarkOverlay.minimumZ = 9;
        self.seamarkOverlay.maximumZ = 18; // fb, 13.3.2014, geändert für die FlyOver-Version. TODO: Muss sehen, ob das später für Offline wieder geändert werden muss.
        
        [self.mapView addOverlay: self.seamarkOverlay level: MKOverlayLevelAboveLabels];
    }    
}

- (void) removeOverlays
{
    if (_baseMapOverlay)
    {
        [self.mapView removeOverlay: _baseMapOverlay];
        _baseMapOverlay = nil;
    }
    if (_seamarkOverlay)
    {
        [self.mapView removeOverlay: _seamarkOverlay];
        _seamarkOverlay = nil;
    }
}

- (void) updateShipPosition
{
    if (self.headlingLine)
    {
        [self.mapView removeOverlay: self.headlingLine];
    }
    
    FBGeoLocation *loc = [MSMLocationManager manager].currentLocation;
    CLLocationCoordinate2D origin = loc.coordinate;
    CLLocationCoordinate2D dest = [MSMGeoUtils destinationForStart: origin distance:loc.speed * 3600.0 bearing:loc.course];
    CLLocationCoordinate2D coords[2] = {origin, dest};
    
    if ([loc hasValidCourseInfo])
    {
        self.headlingLine = [MKPolyline polylineWithCoordinates:coords count:2];
        self.headlingLine.title = @"heading"; // wir nehmen den Title, um verschiedene Polylines unterscheiden zu können
        [self.mapView addOverlay: self.headlingLine];
    }
        
    self.shipView.mapTrackingType = self.mapTrackingType;
    self.shipView.cameraHeading = self.mapView.camera.heading;
    
    [self.shipView setNeedsDisplay];
}



#pragma mark - MapViewDelegate

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass: [MSMLocationManager class]])
    {        
        MSMShipView *shipView = (MSMShipView *)[mapView dequeueReusableAnnotationViewWithIdentifier: @"ship"];
        if (! shipView)
        {
            shipView = [[MSMShipView alloc] initWithAnnotation: [MSMLocationManager manager] reuseIdentifier: @"ship"];

            shipView.frame = CGRectMake(0, 0, 50, 50);
            shipView.canShowCallout = YES;
            shipView.opaque = NO;
        }
        
        self.shipView = shipView;
        
        return shipView;
    }
    else
    {
        return nil;
    }
}

- (MKOverlayRenderer *) mapView: (MKMapView *) mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKTileOverlay class]] )
    {
        return [[MKTileOverlayRenderer alloc] initWithOverlay: overlay];
    }
    if ([overlay isKindOfClass:[MKPolyline class]])
    {
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:(MKPolyline *)overlay];
        if ([overlay.title isEqualToString:@"heading"])
        {
            renderer.lineWidth = 1.5f;
            renderer.strokeColor = [UIColor redColor];
        }
        else
        {
            renderer.lineWidth = 2.0f;
            renderer.strokeColor = [UIColor blueColor];
        }
        
        return renderer;
    }
    
    return nil;
}



@end
