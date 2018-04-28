//
//  MSMTrackDetailTableViewController.m
//  mySeaMap
//
//  Created by Frank Budszuhn on 25.09.16.
//  Copyright © 2016 Frank Budszuhn. See LICENSE.
//

#import <Foundation/Foundation.h>
#import "MSMTrackDetailTableViewController.h"
#import "MSMUtils.h"
#import "MSMGPXExporter.h"

@interface MSMTrackDetailTableViewController ()

@end

@implementation MSMTrackDetailTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = [MSMUtils userFriendlyDate: self.track.startDate];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? 4 : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"TrackDetailCellInfo" forIndexPath:indexPath];
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Start";
                cell.detailTextLabel.text = [MSMUtils userFriendlyDate: self.track.startDate];
                break;
                
            case 1:
                cell.textLabel.text = @"Ende";
                cell.detailTextLabel.text = [MSMUtils userFriendlyDate: self.track.endDate];
                break;
                
            case 2:
                cell.textLabel.text = @"Dauer";
                cell.detailTextLabel.text = [self calcDuration];
                break;
                
            case 3:
                cell.textLabel.text = @"Einträge";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", [self.track.trackEntries count]];
                break;
                
            default:
                break;
        }
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"TrackDetailCellExport" forIndexPath:indexPath];
        cell.textLabel.text = @"GPX";
    }
    
    return cell;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        MSMGPXExporter *exp = [[MSMGPXExporter alloc] initWithTrack: self.track];
        NSURL *trackURL = [exp exportTrack];
        
        
        
        //UIActivityType
        UIActivityViewController* activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[trackURL] applicationActivities:nil];
        activityViewController.completionWithItemsHandler = ^(NSString* activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
            
            [exp deleteTempFile]; // cleanup
            [tableView deselectRowAtIndexPath:indexPath animated:YES];

        };
        [self presentViewController:activityViewController animated:YES completion:nil];
    }
}


// keine Ahnung warum, es ließ sich nicht inline im switch statement einbauen, wtd
- (NSString *) calcDuration
{
    NSDate *endDate = self.track.endDate != nil ? self.track.endDate : [NSDate date]; // ggf. läuft der Track noch
    NSTimeInterval duration = [endDate timeIntervalSinceDate: self.track.startDate];
    return [MSMUtils userFriendlyTimeInterval: duration];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return @"Track Details";
    }
    else {
        return @"Track exportieren";
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
