//
//  MSMViewController.m
//  mySeaMap
//
//  Created by Frank Budszuhn on 04.11.13.
//  Copyright (c) 2013 - 2017 Frank Budszuhn. See LICENSE.
//

@import SafariServices;

#import <MBProgressHUD/MBProgressHUD.h>
#import <MKMapViewZoom/MKMapView+ZoomLevel.h>
#import <LSMessageHUD/LSMessageHUD.h>
#import "MSMViewController.h"
#import "MSMSettingsViewController.h"
#import "MSMZoomSettingsViewController.h"
#import "MSMAboutViewController.h"
#import "MSMSearchViewController.h"
#import "MSMUtils.h"
#import "MSMMapControlsView.h"
#import "FBGeoLocation.h"
#import "MSMGeoUtils.h"
#import "FBOSMNode.h"
#import "MSMGeoUtils.h"
#import "MSMMapObjectDetailTableViewController.h"
#import "MSMPolygonRenderer.h"
#import "MSMCache.h"
#import "MSMCachedTileOverlay.h"
#import "MSMLocationManager.h"
#import "MSMShipView.h"
#import "MSMMapSource.h"
#import "MSMExternalScreen.h"
#import "MSMAppDelegate.h"
#import "MSMTrackManager.h"
#import "MSMTrackListTableViewController.h"
#import "MSMInstrumentsView.h"


@interface MSMViewController () <MKMapViewDelegate, MSMSettingsViewControllerDelegate, MSMMapObjectsViewControllerDelegate, MSMMapViewDelegate, MSMSearchViewControllerDelegate, MSMZoomSettingsViewControllerDelegate, MSMTrackDisplayDelegate, UIGestureRecognizerDelegate, SFSafariViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIStackView *instrumentsStackView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *instrumentsTopLayoutConstraint;
@property (nonatomic) CGFloat instrumentsTopLayoutConstraintConstantInitialValue;
@property (weak, nonatomic) IBOutlet MSMInstrumentsView *undoFullscreenView;

@property (weak, nonatomic) IBOutlet MSMMapControlsView *mapControlsView;
@property (weak, nonatomic) IBOutlet MSMScaleView *scaleView;
@property (weak, nonatomic) IBOutlet UILabel *scaleLabel;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *crossHairPositionButtonItem;
@property (weak, nonatomic) IBOutlet UIButton *crossHairPositionButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *mapInfoItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *trackingButton;
@property (weak, nonatomic) IBOutlet UIButton *undoFullScreenButton;

@property (strong, nonatomic) MSMMapObject *currentActiveMapObject; // der MapObject unter dem Fadenkreuz

@property (weak, nonatomic) IBOutlet MSMInstrumentsView *speedAndCourseView;
@property (weak, nonatomic) IBOutlet MSMInstrumentsView *latAndLonView;
@property (weak, nonatomic) IBOutlet MSMInstrumentsView *bigSpeedView;
@property (weak, nonatomic) IBOutlet MSMInstrumentsView *bigCourseView;


@property (weak, nonatomic) IBOutlet UILabel *latitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *longitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *courseLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UILabel *bigSpeedLabel;
@property (weak, nonatomic) IBOutlet UILabel *bigCourseLabel;

@end

@implementation MSMViewController



- (void)viewDidLoad
{
    // NavBar und ToolBar einrichten
    [self setupBars];
    
    // setupLabels
    [self setupLabels];

    [super viewDidLoad];
    
    // Hier merken wir uns den initalen Abstand aus dem Storyboard, damit wir ihn nicht hartverdrahten müssen.
    self.instrumentsTopLayoutConstraintConstantInitialValue = self.instrumentsTopLayoutConstraint.constant;

    [self.undoFullScreenButton setImage:[StyleKit imageOfCollapse] forState:UIControlStateNormal];
    
    // und den Recognizer dazu
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.mapView addGestureRecognizer: tapGestureRecognizer];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"BUTTON_MAP", nil) style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
    MSMMapSource *mapSource = [MSMMapSource mapSourceFromUserDefaults];
    
    self.mapControlsView.drawColor = [mapSource controllsDrawColour];
    self.scaleLabel.textColor = [mapSource controllsDrawColour];
    self.scaleView.hidden = ![MSMUtils userDefaultForKey: USER_DEFAULTS_SCALE];
    self.mapView.rotateEnabled = [MSMUtils userDefaultForKey: USER_DEFAULTS_ROTATE_TILT withDefault: NO];
    self.mapView.pitchEnabled = NO;
    self.mapView.showsUserLocation = NO;
    
    // Instrumente
    BOOL isBigInstruments = [MSMUtils userDefaultForKey:USER_DEFAULTS_BIG_INSTRUMENTS withDefault:NO];
    self.speedAndCourseView.hidden = isBigInstruments;
    self.latAndLonView.hidden = isBigInstruments;
    self.bigCourseView.hidden = !isBigInstruments;
    self.bigSpeedView.hidden = !isBigInstruments;

        
    // http://stackoverflow.com/questions/5556977/determine-if-mkmapview-was-dragged-moved
    UIPanGestureRecognizer* panRec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didDragMap:)];
    [panRec setDelegate:self];
    [self.mapView addGestureRecognizer:panRec];
    
    // Kartenausschnitt sichern, wenn wir in den Hintergrund gehen
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(saveMapState)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(positionChanged:)
                                                 name: NOTIFICATION_POSITION_CHANGED
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(locationManagerChanged:)
                                                 name: NOTIFICATION_LOCATION_MANAGER_CHANGE
                                               object: nil];

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(openUrl)
                                                 name: NOTIFICATION_OPEN_URL
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(notifyMapSourceChanged:)
                                                 name: NOTIFICATION_MAP_SOURCE_CHANGED
                                               object: nil];
    
    [self showNavigationWarningAlert];
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self displayLocation: [[MSMLocationManager manager] currentLocation]];
}


// MARK: - Trait Collection
- (void) traitCollectionDidChange: (UITraitCollection *) previousTraitCollection
{
    [super traitCollectionDidChange: previousTraitCollection];
    
    // falls wir beim Start eine Url bekommen haben
    // wenn wir es nicht hier machen, dann verrutscht die Position leicht durch die Änderung der Trait Collection
    MSMAppDelegate *appDelegate = (MSMAppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate.externalLaunchParams) {
        [self openUrl];
    }
    
    [self updateCurrentMapObject];
    
    // und das Schiff nachführen, weil das Kreuz ggf "gesprungen" ist
    // 29.12,16 - und bugfix dazu: das darf nur passieren, wenn wir der Position auch folgen!
    if (self.mapTrackingType == MSMMapTrackingTypeOn || self.mapTrackingType == MSMMapTrackingTypeHeading) {
        
        FBGeoLocation *currentLocation = [[MSMLocationManager manager] currentLocation];
        [self.mapView setCenterCoordinate: currentLocation.coordinate];
    }
}



// location kann nil sein
// von der Location machen wir auch abhängig, ob der Copy-Button funktioniert
- (void) displayLocation: (FBGeoLocation *) location
{
    if (location)
    {
        BOOL isInaccurate = location.accuracy > 50.0; // wir sagen erstmal alles unter 50m ist ok
        
        UIColor *col = isInaccurate ? [UIColor redColor] : [UIColor blackColor];
        
        self.latitudeLabel.textColor = col;
        self.latitudeLabel.text = [location formattedLatitude];
        
        self.longitudeLabel.textColor = col;
        self.longitudeLabel.text = [location formattedLongitude];
        
        self.courseLabel.textColor = col;
        self.courseLabel.text = [location formattedCourse];
        
        self.speedLabel.textColor = col;
        self.speedLabel.text = [location formattedSpeed];
        
        self.bigSpeedLabel.textColor = col;
        self.bigSpeedLabel.text = [location formattedSpeed];
        
        self.bigCourseLabel.textColor = col;
        self.bigCourseLabel.text = [location formattedCourse];
    }
    else
    {
        self.latitudeLabel.text = @"---";
        self.longitudeLabel.text = @"---";
        self.courseLabel.text = @"---";
        self.speedLabel.text = @"---";
        
        self.bigSpeedLabel.text = @"---";
        self.bigCourseLabel.text = @"---";
    }
}


- (void) setupBars
{
    // ToolBar
    self.mapInfoItem.title = nil;
    
    UIColor *fontColor = self.view.tintColor;
    UIImage *crossHairImage = [StyleKit imageOfCrossHairWithImageSize:CGSizeMake(21, 21) crossHairStrokeColor:[UIColor blackColor] crossHairStrokeWidth:1];
    [self.crossHairPositionButton setImage:[crossHairImage imageWithRenderingMode: UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.crossHairPositionButton setTitleColor: fontColor forState:UIControlStateNormal];
    
    CGFloat hue, saturation, brightness, alpha ;
    [fontColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha] ;
    UIColor *darkFontColor = [ UIColor colorWithHue:hue saturation:saturation brightness:brightness -0.5 alpha:alpha ] ;
    
    [self.crossHairPositionButton setTitleColor: darkFontColor forState:UIControlStateHighlighted];
    [[self.crossHairPositionButton titleLabel] setFont:[UIFont monospacedDigitSystemFontOfSize:16 weight:UIFontWeightRegular]];

    self.crossHairPositionButton.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 3.0f, 0.0f, 0.0f);
}

- (void) setupLabels
{
    // proportionalen Font für die Instrumente setzen
    [self.latitudeLabel setFont:[UIFont monospacedDigitSystemFontOfSize:24 weight:UIFontWeightSemibold]];
    [self.longitudeLabel setFont:[UIFont monospacedDigitSystemFontOfSize:24 weight:UIFontWeightSemibold]];
    [self.speedLabel setFont:[UIFont monospacedDigitSystemFontOfSize:24 weight:UIFontWeightSemibold]];
    [self.courseLabel setFont:[UIFont monospacedDigitSystemFontOfSize:24 weight:UIFontWeightSemibold]];
    
    [self.bigSpeedLabel setFont:[UIFont monospacedDigitSystemFontOfSize:37 weight:UIFontWeightSemibold]];
    [self.bigCourseLabel setFont:[UIFont monospacedDigitSystemFontOfSize:37 weight:UIFontWeightSemibold]];
}

// verhindert, dass sich mehrere Recognizer in die Quere kommen
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)didDragMap:(UIGestureRecognizer*)gestureRecognizer
{
    static BOOL needsReset = NO;
    
    if (self.mapTrackingType != MSMMapTrackingTypeOff)
    {
        needsReset = self.mapTrackingType == MSMMapTrackingTypeHeading;
        self.mapTrackingType = MSMMapTrackingTypeOff;
        
        self.trackingButton.image = [StyleKit imageOfTrackingOff];
    }
    
    // die Kamera darf erst am Ende zurück gesetzt werden, sonst funktioniert der Drag nicht mehr :-(
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded && needsReset)
    {
        MKMapCamera *cam = [self.mapView.camera copy];
        cam.heading = 0.0;
        [self.mapView setCamera: cam animated:YES];
        needsReset = NO;
    }
    
    [self updatePositionItem];
    [self updateCurrentMapObject];
    [self updateShipPosition];
}

- (void) trackingOff
{
    [self setTrackingType: MSMMapTrackingTypeOff];
}


#pragma mark - target / action


- (IBAction) switchTrackingMode
{
    [self setTrackingType: (self.mapTrackingType + 1) % 3];
}


- (IBAction)toggleInstruments:(id)sender
{
    [self.view layoutIfNeeded];
    CGFloat targetConstraintConstant;
    CGFloat targetStackViewAlpha;
    BOOL instrumentsAreCurrentlyVisible = self.instrumentsTopLayoutConstraint.constant == self.instrumentsTopLayoutConstraintConstantInitialValue;
    
    if (instrumentsAreCurrentlyVisible) {
        targetConstraintConstant = -70;
        targetStackViewAlpha = 0.0;
        
    }
    else {
        targetConstraintConstant = self.instrumentsTopLayoutConstraintConstantInitialValue;
        targetStackViewAlpha = 1.0;
    }
    
    self.instrumentsTopLayoutConstraint.constant = targetConstraintConstant;
    [UIView animateWithDuration:0.5 animations:^{
        self.instrumentsStackView.alpha = targetStackViewAlpha;
        [self.view layoutIfNeeded];
    }];
}



- (IBAction)setFullScreen:(id)sender
{
    [self.navigationController setToolbarHidden:YES animated:YES];
    [self.navigationController setNavigationBarHidden:YES animated:YES];

    self.undoFullscreenView.hidden = NO;
    self.mapControlsView.isDrawCrosshairs = NO; // kein Fadenkreuz im Fullscreen
    
    //  move legal text
    UILabel *attributionLabel = [self.mapView.subviews objectAtIndex:1];
    attributionLabel.center = CGPointMake(attributionLabel.center.x + 45.0, attributionLabel.center.y);
}

- (IBAction)undoFullScreen:(id)sender
{
    [self.navigationController setToolbarHidden:NO animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.undoFullscreenView.hidden = YES;
    self.mapControlsView.isDrawCrosshairs = [MSMUtils userDefaultForKey: USER_DEFAULTS_CROSSHAIRS];
}


- (IBAction)unwindFromPopover:(UIStoryboardSegue *)unwindSegue
{
    //NSLog(@"## unwind ###");
}


- (IBAction)info:(id)sender
{
    if (self.currentActiveMapObject)
    {
        [self openInfoForMapObject: self.currentActiveMapObject barButtonItem: sender orRect:CGRectNull];
    }
}

- (IBAction)tap:(id)sender
{
    UITapGestureRecognizer *gestureRecognizer = sender;
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded)
        return;
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    MSMMapObject *mapObject = [MSMCache nearestMapObjectToLocation:touchMapCoordinate maxDistance: TAP_DISTANCE];
    if (mapObject)
    {
        CGPoint nodePoint = [self.mapView convertCoordinate: mapObject.coordinate toPointToView:self.mapView];
        [self openInfoForMapObject: mapObject barButtonItem:nil orRect:CGRectMake(nodePoint.x, nodePoint.y, 1.0, 1.0)];
    }
}


- (IBAction)positionCopy:(UIButton *)sender
{
    FBGeoLocation *geoLocation = [[FBGeoLocation alloc] init];
    geoLocation.coordinate = [self mapCenterCoordinate];

    UIPasteboard *appPasteBoard = [UIPasteboard generalPasteboard];
    appPasteBoard.persistent = YES;
    [appPasteBoard setString: [geoLocation pasteboardRepresentation]];
    
    [LSMessageHUD showWithMessage: NSLocalizedString(@"COPY_MESSAGE", nil)];
}


// Popover für Details
- (void) openInfoForMapObject: (MSMMapObject *) mapObject barButtonItem: (UIBarButtonItem *) sender orRect: (CGRect) rect
{
    UINavigationController *navCtr = [self.storyboard instantiateViewControllerWithIdentifier:STORYBOARD_NAV_INFO_CONTROLLER];
    
    MSMMapObjectDetailTableViewController *mapObjectVC = (MSMMapObjectDetailTableViewController*)navCtr.topViewController;
    mapObjectVC.mapObject = mapObject;
    mapObjectVC.delegate = self;
    
    navCtr.preferredContentSize = CGSizeMake(320, [mapObject heightForPopover]);
    navCtr.modalPresentationStyle = UIModalPresentationPopover;
    
    // Get the popover presentation controller and configure it.
    UIPopoverPresentationController *presentationController = [navCtr popoverPresentationController];
    presentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    presentationController.delegate = mapObjectVC;
    
    if (sender) {
        presentationController.barButtonItem = sender;
    }
    else {
        presentationController.sourceView = self.mapView;
        presentationController.sourceRect = rect;
    }
    
    [self presentViewController: navCtr animated:YES completion:nil];
}

#pragma mark - MSMSearchViewController delegate

- (void) searchDone
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) setPlacemark:(CLPlacemark *)placemark
{
    [self dismissViewControllerAnimated:YES completion:^{
        MKCoordinateRegion mkRegion = MKCoordinateRegionMakeWithDistance(placemark.location.coordinate, 5000.0, 5000.0);
        
        [self.mapView setRegion: mkRegion animated:YES];
    }];
}

#pragma mark - MapView Delegate





- (void) mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    MKMapRect mRect = self.mapView.visibleMapRect;
    MKMapPoint westMapPoint = MKMapPointMake(MKMapRectGetMinX(mRect), MKMapRectGetMaxY(mRect));
    MKMapPoint eastMapPoint = MKMapPointMake(MKMapRectGetMaxX(mRect), MKMapRectGetMaxY(mRect));
 
    CLLocationDistance dist = MKMetersBetweenMapPoints(eastMapPoint, westMapPoint);

    BOOL isRotatedOrTilted = fabs(mapView.camera.heading) > 0.05 || fabs(mapView.camera.pitch) > 0.05;
    if (isRotatedOrTilted)
    {
        _scaleView.hidden = YES;
    }
    else
    {
        _scaleView.hidden = ! [MSMUtils userDefaultForKey:USER_DEFAULTS_SCALE];
        BOOL isMetric = [MSMUtils userDefaultForKey:USER_DEFAULTS_UNITS_METRIC withDefault: NO];
        double meters;
        NSString *text;
        
        if (isMetric) {
            
            double scaleKM = [MSMGeoUtils scaleWidthForMapWidth: dist/1000.0 inOrientation: self.interfaceOrientation];
            text = scaleKM >= 1.0 ? [NSString stringWithFormat:@"%.0f km", scaleKM] : [NSString stringWithFormat:@"%.2f km", scaleKM];
            
            meters = scaleKM * 1000.0;
        }
        else {
            double nauticalMiles = dist / NAUTICAL_MILE;
            
            double scaleMiles = [MSMGeoUtils scaleWidthForMapWidth: nauticalMiles inOrientation: self.interfaceOrientation];
            text = scaleMiles >= 1.0 ? [NSString stringWithFormat:@"%.0f NM", scaleMiles] : [NSString stringWithFormat:@"%.2f NM", scaleMiles];
            
            meters = scaleMiles * NAUTICAL_MILE;
        }
        
        double mapPoints = eastMapPoint.x - westMapPoint.x;
        double mapPixel = mapView.frame.size.width;
        
        double mpp = MKMapPointsPerMeterAtLatitude(MKCoordinateForMapPoint(westMapPoint).latitude);
        
        // hier der neue Scale
        self.scaleView.scaleDrawWidth = meters * mpp / (mapPoints / mapPixel);
        self.scaleLabel.text = text;
        [self.scaleView setNeedsDisplay];
        
        self.shipView.mapScaleFactor = mpp / (mapPoints / mapPixel);
        [self.shipView setNeedsDisplay];
    }
    
    
    [self updatePositionItem];
    [self updateShipPosition];
    
    [[self externalScreen] setRegion: self.mapView.region];
    
    if (dist < 30000)
    {
        @autoreleasepool {
            // und Abfrage der Overpass-API
            WEAK_SELF(weakSelf);
            [MSMCache queryMapObjectsForMapRect:mapView.visibleMapRect success:^(NSArray *mapObjects) {
                
                MSMMapObject *mapObject = [MSMCache nearestMapObjectToLocation:[self mapCenterCoordinate] maxDistance: TAP_DISTANCE];
                if (mapObject)
                {
                    weakSelf.currentActiveMapObject = mapObject;
                }
                else
                {
                    weakSelf.currentActiveMapObject = nil;
                }
                
                [weakSelf updateCurrentMapObject];
            }];
        } // auto
    }
}


// fb, 21.12.16 - Optimierung : Toolbar wird nur neu gesetzt, wenn sich auch etwas geändert hat
- (void) showCrosshairsInToolbar: (BOOL) show
{
    NSMutableArray *toolBarItems = [self.toolbarItems mutableCopy];
    
    if (show && ! [toolBarItems containsObject:self.crossHairPositionButtonItem])
    {
        [toolBarItems insertObject:self.crossHairPositionButtonItem atIndex:0];
        [self setToolbarItems: toolBarItems animated:YES];
    }
    else if (! show && [[toolBarItems firstObject] isEqual: self.crossHairPositionButtonItem])
    {
        [toolBarItems removeObjectAtIndex:0];
        [self setToolbarItems: toolBarItems animated:YES];
    }
}

- (void) updatePositionItem
{
    FBGeoLocation *geoLocation = [[FBGeoLocation alloc] init];
    geoLocation.coordinate = [self mapCenterCoordinate];
    
    [self.crossHairPositionButton setTitle:[geoLocation nauticalDescription] forState:UIControlStateNormal];
}


- (void) updateCurrentMapObject
{
    if (self.currentActiveMapObject)
    {
        
        if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) {
            
            [self showCrosshairsInToolbar: NO];
            [self.crossHairPositionButton setTitle:nil forState:UIControlStateNormal];
        }

        self.mapInfoItem.title = self.currentActiveMapObject.title;
    }
    else
    {
        self.mapInfoItem.title = nil;
        
        [self showCrosshairsInToolbar: YES];
    }

}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Position / Ausschnitt, ggf. andere Dinge sichern, auch in die User-Defaults!
    [self saveMapState];
    
    // keine Ahnung, ob das hier viel bringt...
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}


// Position der Kartenmitte. Bugfix, 16.12.16 - man darf dafür *NICHT* mapView.centerCoordinate nehmen, die ist ungenau!!!
- (CLLocationCoordinate2D) mapCenterCoordinate
{
    CGPoint p = CGPointMake(self.mapView.bounds.size.width/2.0, self.mapView.bounds.size.height/2.0);
    
    p.y += [MSMUtils statusBarOffsetForRead: YES]; // WICHTIG: gleicht das verschobene Kreuz im Controlview aus.
    
    return [self.mapView convertPoint:p toCoordinateFromView:nil];
}


#pragma mark - Segue

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // fb, 1.10.15, hihi, scheint so zu gehen eventuell noch offene Popovers zu schließen
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];

    if ([segue.identifier isEqualToString:SEGUE_SETTINGS])
    {
        MSMSettingsViewController *settingsCtr;
        UINavigationController *navCtr = segue.destinationViewController;
        settingsCtr = (MSMSettingsViewController *)navCtr.topViewController;        
        settingsCtr.delegate = self;
        settingsCtr.mapViewDelegate = self;
        segue.destinationViewController.popoverPresentationController.delegate = settingsCtr;
    }
    else if ([segue.identifier isEqualToString:SEGUE_MAPOBJECT_DETAIL])
    {
        // nur iPhone
        MSMMapObjectDetailTableViewController *mapObjectVC = segue.destinationViewController;
        mapObjectVC.mapObject = sender;
        // FIXME: mapObjectVC.delegate = self;
    }
    else if ([segue.identifier isEqualToString:SEGUE_SEARCH])
    {
        MSMSearchViewController *searchVC = segue.destinationViewController;
        searchVC.delegate = self;
    }
    else if ([segue.identifier isEqualToString:SEGUE_ABOUT] && [MSMUtils isIPad]) {
        UINavigationController *navCtr = segue.destinationViewController;
        MSMAboutViewController *aboutVC = (MSMAboutViewController *) navCtr.topViewController;
        segue.destinationViewController.popoverPresentationController.delegate = aboutVC;
    }
    else if ([segue.identifier isEqualToString:SEGUE_TRACK_LIST]) {
        UINavigationController *navCtr = segue.destinationViewController;
        MSMTrackListTableViewController *trackListVC = (MSMTrackListTableViewController *)navCtr.topViewController;
        trackListVC.trackDisplayDelegate = self;
    }
}

#pragma mark - Position handling

- (void) positionChanged: (NSNotification *) notification
{
    NSDictionary *userInfo = [notification userInfo];
    FBGeoLocation *loc = [userInfo valueForKey:@"loc"];
    
    [self displayLocation:loc];
    
    if (self.mapTrackingType != MSMMapTrackingTypeOff)
    {
        [self.mapView setCenterCoordinate: loc.coordinate animated:YES];
        
        if (self.mapTrackingType == MSMMapTrackingTypeHeading && loc.course >= 0.0)
        {
            // heading
            MKMapCamera *cam = [self.mapView.camera copy];
            // bugfix: durch das Setzen von negativen Gradwerten werden "Rotationpirouetten" bei der Animation vermieden
            cam.heading = loc.course > 180.0 ? loc.course - 360.0 : loc.course;
            [self.mapView setCamera: cam animated:YES];
        }
    }
    
    [self updateShipPosition];
}

- (void) locationManagerChanged: (NSNotification *) notification
{
    //[self updateGeoLocationView]; ####
}

#pragma mark - open url


- (void) openUrl
{
    MSMAppDelegate *appDelegate = (MSMAppDelegate *)[UIApplication sharedApplication].delegate;
    
    if (appDelegate.externalLaunchParams) {
        int zoom = (int)[self.mapView zoomLevel];
        
        if (appDelegate.externalLaunchParams[@"type"]) {
            int mapSourceIndex = [appDelegate.externalLaunchParams[@"type"] intValue];
            MSMMapSource *mapSource = [[MSMMapSource mapSources] objectAtIndex: mapSourceIndex];
            [self mapSourceChanged: mapSource];
            [mapSource saveAsUserDefault];
        }
        if (appDelegate.externalLaunchParams[@"zoom"]) {
            zoom = [appDelegate.externalLaunchParams[@"zoom"] intValue];
        }
        if (appDelegate.externalLaunchParams[@"lat"] && appDelegate.externalLaunchParams[@"lon"]) {
            double lat = [appDelegate.externalLaunchParams[@"lat"] doubleValue];
            double lon = [appDelegate.externalLaunchParams[@"lon"] doubleValue];
            
            CLLocationCoordinate2D c;
            c.latitude = lat;
            c.longitude = lon;
            
            [self.mapView setCenterCoordinate:c zoomLevel:zoom animated:YES];

            // ein Pin macht nur Sinn, wenn auch eine Position gesetzt worden ist
            if (appDelegate.externalLaunchParams[@"pin"]) {
                
                // die alte Annotation soll weg
                [self.mapView removeAnnotations:[self.mapView annotations]];
                
                NSString *value = appDelegate.externalLaunchParams[@"pin"];
                if (! [@"false" isEqualToString: [value lowercaseString]]) {
                    
                    MKPointAnnotation *pinPoint = [[MKPointAnnotation alloc] init];
                    pinPoint.coordinate = c;
                    
                    if (! [@"true" isEqualToString: [value lowercaseString]]) {
                        pinPoint.title = [value stringByRemovingPercentEncoding];
                    }
                    
                    [self.mapView addAnnotation: pinPoint];
                    [self.mapView selectAnnotation:pinPoint animated:NO];
                }
            }
        }
        
        appDelegate.externalLaunchParams = nil;
    }
}

#pragma mark - map state handling

- (void) saveMapState
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    [def setDouble:self.mapView.region.center.latitude forKey:USER_DEFAULTS_MAP_CENTER_LAT];
    [def setDouble:self.mapView.region.center.longitude forKey:USER_DEFAULTS_MAP_CENTER_LON];
    [def setDouble:self.mapView.region.span.latitudeDelta forKey:USER_DEFAULTS_MAP_SPAN_LAT];
    [def setDouble:self.mapView.region.span.longitudeDelta forKey:USER_DEFAULTS_MAP_SPAN_LON];
    [def synchronize];
}

- (void) loadMapState
{
    [super loadMapState];
    
    // und die Skalierung
    double scaleFactor = [[NSUserDefaults standardUserDefaults] doubleForKey: USER_DEFAULTS_MAP_SCALE_FACTOR];
    if (scaleFactor < 1.0)
    {
        // Fallback, wenn nicht gesetzt
        scaleFactor = 1.0;
    }
    
    self.mapView.transform = CGAffineTransformMakeScale(scaleFactor, scaleFactor);
}

#pragma mark - MSMNodeDetailViewControllerDelegate

- (void) showUrl:(NSDictionary *)urlInfo
{
    // TODO: das ist ein bischen schräg hier. Können aus einem der beiden Popovers aufgerufen worden sein
    NSURL *url = [NSURL URLWithString:urlInfo[@"url"]];
    SFSafariViewController *safari = [[SFSafariViewController alloc] initWithURL: url];
    safari.delegate = self;
    
    // dieses Gegurke machen wir, weil wir sonst aus einem PopOver nicht presentieren können
    UIViewController *presentingViewController = [[[UIApplication sharedApplication] delegate] window].rootViewController;
    while(presentingViewController.presentedViewController != nil)
    {
        presentingViewController = presentingViewController.presentedViewController;
    }
    
    [presentingViewController presentViewController:safari animated:YES completion:nil];
}


// fb, 14.4.16, diese Methode aus dem Delegate genommen. Es wird nun durch eine Notification erreicht.
- (void) mapSourceChanged:(MSMMapSource *)mapSource
{
    [self setMapSource: mapSource];
    self.mapControlsView.drawColor = [mapSource controllsDrawColour];
    self.scaleLabel.textColor = [mapSource controllsDrawColour];
}

- (void) notifyMapSourceChanged: (NSNotification *) notification
{
    MSMMapSource *mapSource = notification.userInfo[@"mapSource"];
    [self mapSourceChanged: mapSource];
}

#pragma mark - MSMSettingsViewControllerDelegate

- (void) showBigInstruments: (BOOL) bigInstruments {
        
    self.speedAndCourseView.hidden = bigInstruments;
    self.latAndLonView.hidden = bigInstruments;
    self.bigSpeedView.hidden = !bigInstruments;
    self.bigCourseView.hidden = !bigInstruments;
    
    [[NSUserDefaults standardUserDefaults] setBool:bigInstruments forKey:USER_DEFAULTS_BIG_INSTRUMENTS];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) showScale:(BOOL)show
{
    BOOL isRotatedOrTilted = self.mapView.camera.heading != 0.0 || self.mapView.camera.pitch != 0.0;
    
    self.scaleView.hidden = !(show && ! isRotatedOrTilted);

    [[NSUserDefaults standardUserDefaults] setBool:show forKey:USER_DEFAULTS_SCALE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) showCrosshairs:(BOOL)show
{
    self.mapControlsView.isDrawCrosshairs = show;
    [[NSUserDefaults standardUserDefaults] setBool:show forKey:USER_DEFAULTS_CROSSHAIRS];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void) measurementSystemChanged: (BOOL) isMetric {
    
    // das geht so am Einfachsten
    [self mapView: self.mapView regionDidChangeAnimated: NO];
}


- (void) setTrackingType: (MSMMapTrackingType) type
{
    if (type == self.mapTrackingType)
        return;
    
    FBGeoLocation *currentLocation = [[MSMLocationManager manager] currentLocation];
    CLLocationDirection heading = 0.0;
    self.mapTrackingType = type;
    
    if (type == MSMMapTrackingTypeOff)
    {
        self.trackingButton.image = [StyleKit imageOfTrackingOff];
    }
    else if (type == MSMMapTrackingTypeOn)
    {
        self.trackingButton.image = [StyleKit imageOfTrackingOn];
    }
    else
    {
        self.trackingButton.image = [StyleKit imageOfTrackingHeading];
        if (currentLocation.course > 0.0)
        {
            heading = currentLocation.course;
        }
    }
    
    if (type != MSMMapTrackingTypeOff)
    {
        // auf eigene Position setzen
        [self.mapView setCenterCoordinate:currentLocation.coordinate animated:YES];
    }
    
    // heading
    MKMapCamera *cam = [self.mapView.camera copy];
    cam.heading = heading;
    [self.mapView setCamera: cam animated:YES];
}


#pragma mark - MSMZoomSettingsViewControllerDelegate

- (void) setScaleFacor:(double)scaleFactor
{
    [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
        self.mapView.transform = CGAffineTransformMakeScale(scaleFactor, scaleFactor);
    } completion: ^(BOOL finished){
         self.mapView.frame = self.mapControlsView.frame; // beim Skalieren wird der Frame vergrößert oder verkleinert. Hier setzen wir ihn auf die Größe zurück, die er haben soll.
     }];
    
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    [defs setDouble:scaleFactor forKey:USER_DEFAULTS_MAP_SCALE_FACTOR];
    [defs synchronize];
}

- (void) zoomDone
{
    // TODO: fb, 1.10.15, reicht das so?
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void) allowRotateAndTilt:(BOOL)allow
{
    self.mapView.rotateEnabled = allow;
    self.mapView.pitchEnabled = NO;
    [[NSUserDefaults standardUserDefaults] setBool:allow forKey:USER_DEFAULTS_ROTATE_TILT];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    MKMapCamera *cam = [self.mapView.camera copy];
    if (! allow && (cam.heading != 0.0 || cam.pitch != 0.0))
    {
        cam.heading = 0.0;
        cam.pitch = 0.0;
        [self.mapView setCamera: cam animated:YES];
    }
}



#pragma mark - MSMMapViewDelegate

- (void) setRegion:(MKCoordinateRegion)region
{
    [self.mapView setRegion: region animated: YES];
}


#pragma mark - MSMTrackDisplayDelegate

- (void) addTrack: (MKPolyline *) trackLine
{
    [self.mapView addOverlay: trackLine];
}

- (void) removeTrack: (MKPolyline *) trackLine
{
    [self.mapView removeOverlay: trackLine];
}


#pragma mark - Zugriff auf externen Screen

- (MSMExternalScreen *) externalScreen
{
    MSMExternalScreen *screen = [MSMExternalScreen sharedInstance];
    
    if (screen.window)
    {
        return screen;
    }
    else
    {
        return nil; // not setup
    }
}


@end
