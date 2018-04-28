//
//  MSMSettingsViewController.m
//  mySeaMap
//
//  Created by Frank Budszuhn on 04.11.13.
//  Copyright (c) 2013 - 2017 Frank Budszuhn. See LICENSE.
//

#import "MSMSettingsViewController.h"
#import "MSMUtils.h"
#import "MSMLocationManager.h"
#import "MSMZoomSettingsViewController.h"
#import "MSMFeatureManager.h"
#import "MSMAppDelegate.h"
#import "MSMMapSource.h"


#define TAG_SWITCH_CROSSHAIRS       1
#define TAG_SWITCH_SCALE            2
#define TAG_SWITCH_ROTATE_TILT      3
#define TAG_SWITCH_NIGHT_MODE       4
#define TAG_SWITCH_BIG_INSTRUMENTS  5


@interface MSMSettingsViewController ()

@end



@implementation MSMSettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"TITLE_SETTINGS", nil);
    self.navigationController.navigationBar.translucent = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIPopoverPresentationControllerDelegate

- (void)prepareForPopoverPresentation:(UIPopoverPresentationController *)popoverPresentationController
{
    // This method is only called if we are presented in a popover
    // im Popover schmeißen wir den done-Button weg
    self.navigationItem.rightBarButtonItems = @[];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#if MSM_DEVELOPER
    return 5;
#else
    return 4; // TODO: Offline ist raus
#endif
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) // Kartentyp
        return [[MSMMapSource mapSources] count];
    else if (section == 1)
        return 2;
    else if (section == 2) // Karteneinstellungen
        return [MSMUtils isRetina] ? 3 : 2;
    else if (section == 3) // Kartenelemente
        return [MSMFeatureManager hasFeature: MSMFeatureNightMode] ? 4 : 3;
    else
        return 1; // Dev Menu
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SettingsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.accessoryView = nil; // Reuse issue
    MSMMapSource *currentMapSource = [MSMMapSource mapSourceFromUserDefaults];
    
    if (indexPath.section == 0)
    {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        MSMMapSource *mapSource = [[MSMMapSource mapSources] objectAtIndex: indexPath.row];
        cell.textLabel.text = mapSource.name;        
        cell.accessoryType = [currentMapSource isEqual: mapSource] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }
    else if (indexPath.section == 1) {
        
        BOOL isMetric = [MSMUtils userDefaultForKey:USER_DEFAULTS_UNITS_METRIC withDefault: NO];
        
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"km/h - km";
                cell.accessoryType = isMetric ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                break;
                
            case 1:
                cell.textLabel.text = @"kn - sm";
                cell.accessoryType = isMetric ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
                break;
                
            default:
                break;
        }
    }
    else if (indexPath.section == 2) // Karteneinstellungen
    {
        BOOL isBigInstruments = [MSMUtils userDefaultForKey:USER_DEFAULTS_BIG_INSTRUMENTS withDefault:NO];
        
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = NSLocalizedString(@"CACHE_SETTINGS", nil);
                break;
                
            case 1:
                if ([MSMUtils isRetina]) {
                    cell.textLabel.text = NSLocalizedString(@"MAGNIFICATION", nil);
                }
                else {
                    cell.textLabel.text = NSLocalizedString(@"BIG_INSTRUMENTS", nil);
                    UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectZero];
                    sw.tag = TAG_SWITCH_BIG_INSTRUMENTS;
                    sw.on = isBigInstruments;
                    [sw addTarget:self action:@selector(switchClicked:) forControlEvents:UIControlEventTouchUpInside];
                    cell.accessoryView = sw;                    
                }
                break;
                
            case 2: {
                cell.textLabel.text = NSLocalizedString(@"BIG_INSTRUMENTS", nil);
                UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectZero];
                sw.tag = TAG_SWITCH_BIG_INSTRUMENTS;
                sw.on = isBigInstruments;
                [sw addTarget:self action:@selector(switchClicked:) forControlEvents:UIControlEventTouchUpInside];
                cell.accessoryView = sw;
            }
            break;

            default:
                break;
        }
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.section == 3)
    {
        MSMAppDelegate *appDelegate = (MSMAppDelegate *)[UIApplication sharedApplication].delegate;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSInteger index = [MSMFeatureManager hasFeature: MSMFeatureNightMode] ? indexPath.row : indexPath.row + 1;
        
        switch (index) {
            case 0:
            {
                cell.textLabel.text = @"Nachtmodus";
                
                UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectZero];
                sw.tag = TAG_SWITCH_NIGHT_MODE;
                sw.on = appDelegate.nightMode;
                [sw addTarget:self action:@selector(switchClicked:) forControlEvents:UIControlEventTouchUpInside];
                cell.accessoryView = sw;
            }
            break;
                
            case 1:
            {
                cell.textLabel.text = NSLocalizedString(@"MAP_CONTROL_CROSSHAIRS", nil);

                UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectZero];
                sw.tag = TAG_SWITCH_CROSSHAIRS;
                sw.on = [MSMUtils userDefaultForKey: USER_DEFAULTS_CROSSHAIRS];
                [sw addTarget:self action:@selector(switchClicked:) forControlEvents:UIControlEventTouchUpInside];
                cell.accessoryView = sw;
            }
            break;
                
            case 2:
            {
                cell.textLabel.text = NSLocalizedString(@"MAP_CONTROL_SCALE", nil);
                UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectZero];
                sw.tag = TAG_SWITCH_SCALE;
                sw.on = [MSMUtils userDefaultForKey: USER_DEFAULTS_SCALE];
                [sw addTarget:self action:@selector(switchClicked:) forControlEvents:UIControlEventTouchUpInside];
                cell.accessoryView = sw;
            }
            break;
               
                
            case 3:
            {
                cell.textLabel.text = NSLocalizedString(@"MAP_CONTROL_ROTATE", nil);
                UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectZero];
                sw.tag = TAG_SWITCH_ROTATE_TILT;
                sw.on = [MSMUtils userDefaultForKey: USER_DEFAULTS_ROTATE_TILT withDefault: NO];
                [sw addTarget:self action:@selector(switchClicked:) forControlEvents:UIControlEventTouchUpInside];
                cell.accessoryView = sw;
           }
                break;
                

            default:
                break;
        }
    }
    
    // Dev Menu
    else
    {
        if (indexPath.row == 0)
        {
            cell.textLabel.text = @"Tracks";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }

    return cell;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return NSLocalizedString(@"TABLE_HEADER_MAPTYPE", nil);
    else if (section == 1)
        return NSLocalizedString(@"UNIT_SETTINGS", nil);
    else if (section == 2)
        return NSLocalizedString(@"MAP_SETTINGS", nil);
    else if (section == 3)
        return NSLocalizedString(@"MAP_CONTROL_HEADLINE", Nil);
    else
        return @"Developer";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        MSMMapSource *mapSource = [[MSMMapSource mapSources] objectAtIndex: indexPath.row];
        [mapSource saveAsUserDefault];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MAP_SOURCE_CHANGED object:self userInfo:@{@"mapSource": mapSource}];
                
        [tableView reloadData]; // wg. der "Haken". Kann man auch schöner machen
    }
    else if (indexPath.section == 1) {
        
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        BOOL isMetric = indexPath.row == 0;

        [def setBool:isMetric forKey:USER_DEFAULTS_UNITS_METRIC];

        [def synchronize];
        [tableView reloadData]; // wg. der "Haken". Kann man auch schöner machen
        
        [self.delegate measurementSystemChanged: isMetric]; // refresh UI
    }
    else if (indexPath.section == 2)
    {
        if (indexPath.row == 0)
        {
            [self performSegueWithIdentifier:SEGUE_CACHE_SETTINGS sender:nil];
        }
        else if (indexPath.row == 1)
        {
            [self performSegueWithIdentifier:SEGUE_ZOOM_SETTINGS sender:nil];
        }
    }
    else if (indexPath.section == 4)
    {
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:SEGUE_TRACK_LIST sender:nil];
        }
    }
}


#pragma mark - Segue

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Größe für Popover übernehmen
    UIViewController *vc = segue.destinationViewController;
    vc.preferredContentSize = self.preferredContentSize;
    
    if ([segue.identifier isEqualToString: SEGUE_ZOOM_SETTINGS])
    {
        MSMZoomSettingsViewController *zoomSettingsVC = segue.destinationViewController;
        zoomSettingsVC.delegate = (id <MSMZoomSettingsViewControllerDelegate>)self.delegate; // passt scho...
        zoomSettingsVC.preferredContentSize = self.preferredContentSize;
    }
}


- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated: YES completion:nil];
}


- (void) switchClicked: (UISwitch *) sw
{
    if (sw.tag == TAG_SWITCH_CROSSHAIRS)
    {
        [self.delegate showCrosshairs: sw.on];
    }
    else if (sw.tag == TAG_SWITCH_SCALE)
    {
        [self.delegate showScale:sw.on];
    }
    else if (sw.tag == TAG_SWITCH_ROTATE_TILT)
    {
        [self.delegate allowRotateAndTilt: sw.on];
    }
    else if (sw.tag == TAG_SWITCH_NIGHT_MODE) {
        
        [self setNightMode: sw.on];
    }
    else if (sw.tag == TAG_SWITCH_BIG_INSTRUMENTS) {
        
        [self.delegate showBigInstruments: sw.on];
    }
}

- (void) setNightMode: (BOOL) nightMode
{
    MSMAppDelegate *appDelegate = (MSMAppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.nightMode = nightMode;
    
    if (nightMode)
    {
        // originale Helligkeit sichern, falls der User den Nachtmodus wieder abschaltet
        appDelegate.displayBrightness = [UIScreen mainScreen].brightness;
        [UIScreen mainScreen].wantsSoftwareDimming = YES; // damit bekommt man es noch dunkler
        [UIScreen mainScreen].brightness = 0.01; // es geht zwar auch mit 0, aber wer weiss was da OS updates bringen in der Zukunft.
    }
    else
    {
        [UIScreen mainScreen].wantsSoftwareDimming = NO;
        [UIScreen mainScreen].brightness = appDelegate.displayBrightness;
    }
}


- (CGSize) preferredContentSize
{
    if ([MSMUtils isRetina])
    {
        return CGSizeMake(300, ([[MSMMapSource mapSources] count] + 5) * 44.0 + 300.0);
    }
    else
    {
        return CGSizeMake(300, ([[MSMMapSource mapSources] count] + 4) * 44.0 + 300.0);
    }
}


@end
