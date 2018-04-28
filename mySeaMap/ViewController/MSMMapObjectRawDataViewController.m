//
//  MSMNodeDetailViewController.m
//  mySeaMap
//
//  Created by Frank Budszuhn on 03.12.13.
//  Copyright (c) 2013 Frank Budszuhn. See LICENSE.
//

#import "MSMMapObjectRawDataViewController.h"
#import "MSMUtils.h"


@interface MSMMapObjectRawDataViewController ()

@end

@implementation MSMMapObjectRawDataViewController

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

    self.title = self.mapObject.title;
    self.navigationController.navigationBar.translucent = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    self.navigationController.toolbarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
    
    self.navigationController.toolbarHidden = NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self.mapObject tags] allKeys] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NodeInfoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSString *key = [[[self.mapObject tags] allKeys] objectAtIndex: indexPath.row];
    cell.textLabel.text = key;
    cell.detailTextLabel.text = [[self.mapObject tags] valueForKey: key];
    
    return cell;
}




@end
