//
//  MSMTrackListTableViewController.m
//  mySeaMap
//
//  Created by Frank Budszuhn on 22.09.16.
//  Copyright © 2016 Frank Budszuhn. See LICENSE.
//

#import "MSMTrackListTableViewController.h"
#import "MSMTrackDetailTableViewController.h"
#import "MSMTrackManager.h"
#import "MSMUtils.h"
#import "MSMTrackListTableViewCell.h"


@interface MSMTrackListTableViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *toggleTrackButton;
@property (nonatomic) MSMTrackManager *trackManager;

@end

@implementation MSMTrackListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.trackManager = [MSMTrackManager sharedInstance];
    [self setButtonText];

    // für Location-Events anmelden
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(positionChanged:)
                                                 name: NOTIFICATION_POSITION_CHANGED
                                               object: nil];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[MSMTrackManager sharedInstance] isTracking]? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (! [self.trackManager isTracking]) {
        return [[self.trackManager allTracks] count];
    }
    
    // otherwise: tracking
    if (section == 0) {
        return 1;
    }
    else {
        return [[self.trackManager allTracks] count] - 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MSMTrackListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TrackListCell" forIndexPath:indexPath];
    
    Track *track = [self trackForIndexPath: indexPath];
    NSDate *endDate = track.endDate != nil ? track.endDate : [NSDate date]; // der Track läuft ggf. noch und hat somit noch kein endDate
    
    if ([self.trackManager isVisibleOnMap: track]) {
        cell.imageView.image = [UIImage imageNamed:@"path"];
    }
    else {
        cell.imageView.image = [UIImage imageNamed:@"path_grey"];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%u Einträge", [track.trackEntries count]];
    NSString *startDate = [MSMUtils userFriendlyDate: track.startDate];
    NSTimeInterval duration = [endDate timeIntervalSinceDate:track.startDate];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@", startDate, [MSMUtils userFriendlyTimeInterval: duration]];
    
    // und den Track in der Zelle speichern für Segue
    cell.track = track;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Track *track = [self trackForIndexPath: indexPath];
    [self.trackManager toggleTrackDisplay: track];
    if ([self.trackManager isVisibleOnMap: track]) {
        [self.trackDisplayDelegate addTrack: [self.trackManager polyLineForTrack:track]];
    }
    else {
        [self.trackDisplayDelegate removeTrack: [self.trackManager polyLineForTrack:track]];
    }
    
    // und Zelle refreshen
    [tableView beginUpdates];
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [tableView endUpdates];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if ([self.trackManager isTracking] && section == 0) {
        return @"Laufender Track";
    }
    else {
        return @"Gespeicherte Tracks";
    }
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    // Laufender Track soll nicht gelöscht werden
    return ! ([self.trackManager isTracking] && indexPath.section == 0);
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        // Track besorgen, beim Tracken ist der Index um 1 verschoben!
        NSInteger index = [self.trackManager isTracking] ? indexPath.row + 1 : indexPath.row;
        Track *track = [[self.trackManager allTracks] objectAtIndex:index];
        [self.trackManager deleteTrack:track];

        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}




#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString: SEGUE_TRACK_LIST_DETAILS]) {
        
        MSMTrackListTableViewCell *cell = sender;
        MSMTrackDetailTableViewController *destinationController = [segue destinationViewController];
        
        destinationController.track = cell.track;
    }
}



- (IBAction)toggeTrack:(id)sender
{
    if ([self.trackManager isTracking]) {
        [self.trackManager stopTrack];
    }
    else {
        [self.trackManager startTrack];
    }
    
    [self.tableView reloadData];
    [self setButtonText];
}

- (void) setButtonText {
    self.toggleTrackButton.title = [self.trackManager isTracking] ? @"Stop" : @"Start";
}

#pragma mark - helper

- (Track *) trackForIndexPath: (NSIndexPath *) indexPath
{
    if ([self.trackManager isTracking]) {
        if (indexPath.section == 0) {
            return [[self.trackManager allTracks] objectAtIndex:indexPath.row];
        }
        else {
            return [[self.trackManager allTracks] objectAtIndex:indexPath.row + 1];
        }
    }
    else {
        return [[self.trackManager allTracks] objectAtIndex:indexPath.row];
    }
}


#pragma mark - Location Event

- (void) positionChanged: (NSNotification *) notification
{
//    NSDictionary *userInfo = [notification userInfo];
//    FBGeoLocation *loc = [userInfo valueForKey:@"loc"];
    if ([self.trackManager isTracking]) { // wenn Tracking läuft, wird die erste Zelle upgedated
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];

        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }
}

@end
