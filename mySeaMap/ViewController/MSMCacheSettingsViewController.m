//
//  MSMCacheSettingsViewController.m
//  mySeaMap
//
//  Created by Frank Budszuhn on 24.03.14.
//  Copyright (c) 2014 Frank Budszuhn. See LICENSE.
//

#import <TMCache/TMCache.h>
#import "MSMUtils.h"
#import "MSMCacheSettingsViewController.h"
#import "MSMMapSource.h"

@interface MSMCacheSettingsViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteCacheButton;

@property (strong, nonatomic) TMCache *seamarkCache;
@property (strong, nonatomic) TMCache *overpassCache;

@property (strong, nonatomic) NSByteCountFormatter *byteCountFormatter;

@end

@implementation MSMCacheSettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.deleteCacheButton.title = NSLocalizedString(@"BUTTON_DELETE_CACHE", nil);

    _byteCountFormatter = [[NSByteCountFormatter alloc] init];
    self.byteCountFormatter.countStyle = NSByteCountFormatterCountStyleFile;
    self.byteCountFormatter.allowsNonnumericFormatting = NO;
    
    self.seamarkCache = [[TMCache alloc] initWithName: CACHE_SEAMARKS]; // TODO: ersetzen durch MapSource-Implementierung ###
    self.overpassCache = [[TMCache alloc] initWithName: CACHE_OVERPASS];
}


- (IBAction)deleteCache:(id)sender
{
    NSArray *cachableMapSources = [MSMMapSource cachableBasemapSources];
    NSUInteger mapSourceCount = [cachableMapSources count];
    for (NSUInteger i=0; i<mapSourceCount; i++)
    {
        MSMMapSource *cachableMapSource = [cachableMapSources objectAtIndex:i];
        
        UITableViewCell *aCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        aCell.detailTextLabel.text = NSLocalizedString(@"DELETING", nil);
        [cachableMapSource.cache removeAllObjects:^(TMCache *cache) {
            aCell.detailTextLabel.text = [self.byteCountFormatter stringFromByteCount: cachableMapSource.cache.diskByteCount];
        }];
    }
    
    UITableViewCell *cell2 = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:mapSourceCount inSection:0]];
    cell2.detailTextLabel.text = NSLocalizedString(@"DELETING", nil);
    [self.seamarkCache removeAllObjects:^(TMCache *cache) {
        cell2.detailTextLabel.text = [self.byteCountFormatter stringFromByteCount: self.seamarkCache.diskByteCount];
    }];
    
    UITableViewCell *cell3 = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:mapSourceCount + 1 inSection:0]];
    cell3.detailTextLabel.text = NSLocalizedString(@"DELETING", nil);
    [self.overpassCache removeAllObjects:^(TMCache *cache) {
        cell3.detailTextLabel.text = [self.byteCountFormatter stringFromByteCount: self.overpassCache.diskByteCount];
    }];
}

#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 2 + [[MSMMapSource cachableBasemapSources] count];
    }
    else
    {
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = indexPath.section == 0 ? @"StorageCell" : @"TimeSpanCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    if (indexPath.section == 0)
    {
        NSUInteger mapSourceCount = [[MSMMapSource cachableBasemapSources] count];
        if (indexPath.row < mapSourceCount)
        {
            MSMMapSource *mapSource = [[MSMMapSource cachableBasemapSources] objectAtIndex: indexPath.row];
            cell.textLabel.text = mapSource.name;
            
            // den Cache neu anlegen, damit der diskByteCount aktualisiert wird (passiert sonst nicht)
            TMCache *aCache = [[TMCache alloc] initWithName: mapSource.key];
            cell.detailTextLabel.text = [self.byteCountFormatter stringFromByteCount: aCache.diskByteCount];
        }
        else if (indexPath.row == mapSourceCount)
        {
            cell.textLabel.text = NSLocalizedString(@"SEAMARK_TILES", nil);
            cell.detailTextLabel.text = [self.byteCountFormatter stringFromByteCount: self.seamarkCache.diskByteCount];
        }
        else if (indexPath.row == mapSourceCount + 1)
        {
            cell.textLabel.text = NSLocalizedString(@"OVERPASS_OBJECTS", nil);
            cell.detailTextLabel.text = [self.byteCountFormatter stringFromByteCount: self.overpassCache.diskByteCount];
        }
    }
    else if (indexPath.section == 1)
    {
        MSMCacheDuration cacheDuration = [MSMUtils cacheDuration];
        if (indexPath.row == 0)
        {
            cell.textLabel.text = NSLocalizedString(@"1WEEK", nil);
            cell.accessoryType = cacheDuration == MSMCacheDurationOneWeek ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        }
        else if (indexPath.row == 1)
        {
            cell.textLabel.text = NSLocalizedString(@"1MONTH", nil);
            cell.accessoryType = cacheDuration == MSMCacheDurationOneMonth ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        }
        else if (indexPath.row == 2)
        {
            cell.textLabel.text = NSLocalizedString(@"INDEFINITE", nil);
            cell.accessoryType = cacheDuration == MSMCacheDurationIndefinite ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        }
    }
    
    return cell;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return NSLocalizedString(@"HEADER_STORAGE_USAGE", nil);
    }
    else
    {
        return NSLocalizedString(@"HEADER_STORAGE_TIME", nil);
    }
}

- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 0)
    {
        return NSLocalizedString(@"FOOTER_STORAGE_USAGE", nil);
    }
    else
    {
        return NSLocalizedString(@"FOOTER_STORAGE_TIME", nil);
    }
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:[self rowForDuration:[MSMUtils cacheDuration]] inSection:1];
        if (! [oldIndexPath isEqual: indexPath])
        {
            [[NSUserDefaults standardUserDefaults] setInteger:[self durationForRow:indexPath.row] forKey:USER_DEFAULTS_CACHE_DURATION];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [tableView beginUpdates];
            [tableView reloadRowsAtIndexPaths:@[indexPath, oldIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView endUpdates];
            
            NSTimeInterval newDuration = [MSMUtils cacheDurationInSeconds];
            // FIXME: cache
            self.seamarkCache.diskCache.ageLimit = newDuration;
            self.overpassCache.diskCache.ageLimit = newDuration;
        }
        else
        {
            [tableView deselectRowAtIndexPath: indexPath animated:YES];
        }
    }
}

- (NSInteger) rowForDuration: (MSMCacheDuration) duration
{
    return duration; // geht *erstmal* so
}

- (MSMCacheDuration) durationForRow: (NSInteger) row
{
    return row;
}

@end
