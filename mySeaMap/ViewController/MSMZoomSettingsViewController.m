//
//  MSMZoomSettingsViewController.m
//  mySeaMap
//
//  Created by Frank Budszuhn on 13.05.14.
//  Copyright (c) 2014 Frank Budszuhn. See LICENSE.
//

#import "MSMZoomSettingsViewController.h"

@interface MSMZoomSettingsViewController ()

@end

@implementation MSMZoomSettingsViewController

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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done:(id)sender
{
    [self.delegate zoomDone];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZoomSettingsCell" forIndexPath:indexPath];
    double scaleFactor = [[NSUserDefaults standardUserDefaults] doubleForKey: USER_DEFAULTS_MAP_SCALE_FACTOR];
    if (scaleFactor < 1.0)
        scaleFactor = 1.0;
    
    // Configure the cell...
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"100%";
            cell.accessoryType = scaleFactor == 1.0 ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            break;
            
        case 1:
            cell.textLabel.text = @"150%";
            cell.accessoryType = scaleFactor == 1.5 ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            break;
            
        case 2:
            cell.textLabel.text = @"200%";
            cell.accessoryType = scaleFactor == 2.0 ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    double scaleFactor = [[NSUserDefaults standardUserDefaults] doubleForKey: USER_DEFAULTS_MAP_SCALE_FACTOR];
    if (scaleFactor < 1.0)
        scaleFactor = 1.0;

    NSIndexPath *oldIndexPath;
    if (scaleFactor <= 1.0)
        oldIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    else if (scaleFactor == 1.5)
        oldIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    else if (scaleFactor == 2.0)
        oldIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    
    switch (indexPath.row)
    {
        case 0:
            scaleFactor = 1.0;
            break;
            
        case 1:
            scaleFactor = 1.5;
            break;
            
        case 2:
            scaleFactor = 2.0;
            break;
            
        default:
            scaleFactor = 1.0;
            break;
    }
    
    [self.delegate setScaleFacor: scaleFactor];
    
    if (! [indexPath isEqual: oldIndexPath])
    {
        [tableView beginUpdates];
        [tableView reloadRowsAtIndexPaths:@[indexPath, oldIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView endUpdates];
    }
    else
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}


- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(@"HEADER_MAGNIFICATION", nil);
}

- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return NSLocalizedString(@"FOOTER_MAGNIFICATION", nil);
}

@end
