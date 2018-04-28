//
//  MSMMapObjectDetailTableViewController.m
//  mySeaMap
//
//  Created by Frank Budszuhn on 16.03.14.
//  Copyright (c) 2014 Frank Budszuhn. See LICENSE.
//

@import SafariServices;

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <UIAlertView+Blocks/UIAlertView+Blocks.h>
#import <UITableView-NXEmptyView/UITableView+NXEmptyView.h>
#import "MSMMapObjectDetailTableViewController.h"
#import "MSMMapObjectRawDataViewController.h"
#import "MSMInfoGroup.h"
#import "MSMUtils.h"

@interface MSMMapObjectDetailTableViewController () <MFMailComposeViewControllerDelegate, SFSafariViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *positionItem;
@property (strong, nonatomic) IBOutlet UILabel *emptyView;

@end

@implementation MSMMapObjectDetailTableViewController

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
    
    self.emptyView.text = NSLocalizedString(@"LABEL_EMPTY_VIEW", nil);
    self.tableView.nxEV_emptyView = self.emptyView;
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = self.mapObject.title;
    self.positionItem.title = [self.mapObject nauticalDescription];    
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
    return [self.mapObject.infoGroups count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    MSMInfoGroup *infoGroup = [self.mapObject.infoGroups objectAtIndex: section];
    return [[infoGroup keys] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MSMInfoGroup *infoGroup = [self.mapObject.infoGroups objectAtIndex: indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:infoGroup.cellIdentifier forIndexPath:indexPath];
    
    NSString *key = [[infoGroup keys] objectAtIndex: indexPath.row];
    NSString *value = [[infoGroup values] objectAtIndex: indexPath.row];
    
    if ([infoGroup.cellIdentifier isEqualToString:@"MapObjectNameAndDescription"])
    {
        cell.textLabel.text = value;
    }
    else
    {
        NSString *s = [NSString stringWithFormat:@"key_%@", key];
        cell.textLabel.text = NSLocalizedString(s, nil);
        cell.detailTextLabel.text = value;
    }
    
    return cell;
}


- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[self.mapObject.infoGroups objectAtIndex: section] localizedName];
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 88.0;
    }
    else
    {
        return 44.0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MSMInfoGroup *infoGroup = [self.mapObject.infoGroups objectAtIndex: indexPath.section];
    if ([infoGroup.name isEqualToString:INFO_GROUP_CONTACT])
    {
        NSString *key = [[infoGroup keys] objectAtIndex: indexPath.row];
        NSString *value = [[infoGroup values] objectAtIndex: indexPath.row];
        
        NSDictionary *urlInfo;
        if ([key isEqualToString:@"website"])
        {
            if ([value hasPrefix:@"http://"])
            {
                urlInfo = @{@"url": value, @"title": [self.mapObject title]};
            }
            else
            {
                urlInfo = @{@"url": [NSString stringWithFormat:@"http://%@", value], @"title": [self.mapObject title]};
            }

            if ([MSMUtils isIPad])
            {
                [self.delegate showUrl: urlInfo];
            }
            else
            {
                [self showUrl: urlInfo];
            }
        }
        else if ([key isEqualToString:@"phone"])
        {
            // Anrufen geht nur auf iPhone, gell?
            NSString *phoneUrl = [NSString stringWithFormat:@"tel://%@", [MSMUtils preparePhoneNumber: value]];
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString: phoneUrl]])
            {
                [UIAlertView showWithTitle:NSLocalizedString(@"ALERT_CALL", nil)
                                   message:[NSString stringWithFormat:NSLocalizedString(@"ALERT_PLACE_CALL", nil), value]
                         cancelButtonTitle:NSLocalizedString(@"BUTTON_CANCEL", nil)
                         otherButtonTitles:@[NSLocalizedString(@"BUTTON_CALL", nil)]
                                  tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                      if (buttonIndex != [alertView cancelButtonIndex])
                                      {
                                          [[UIApplication sharedApplication] openURL: [NSURL URLWithString: phoneUrl]];
                                      }
                                  }];
            }
        }
        else if ([key isEqualToString:@"email"])
        {
            [self composeMail: value];
        }
        
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void) showUrl:(NSDictionary *)urlInfo
{
    NSURL *url = [NSURL URLWithString:urlInfo[@"url"]];
    SFSafariViewController *safari = [[SFSafariViewController alloc] initWithURL: url];
    safari.delegate = self;
    
    UIViewController *presentingViewController = [[[UIApplication sharedApplication] delegate] window].rootViewController;
    
    while(presentingViewController.presentedViewController != nil)
    {
        presentingViewController = presentingViewController.presentedViewController;
    }
    
    [presentingViewController presentViewController:safari animated:YES completion:nil];
}



- (void) composeMail: (NSString *) mailAddress
{
    if (! [MFMailComposeViewController canSendMail])
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: NSLocalizedString(@"EMAIL_NOT_CONFIGURED_TITLE", nil)
                              message: NSLocalizedString(@"EMAIL_NOT_CONFIGURED_TEXT", nil)
                              delegate: self
                              cancelButtonTitle: nil
                              otherButtonTitles: @"OK", nil];
        [alert show];
    }
    else
    {
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        [picker setToRecipients: @[mailAddress]];
        
        [self presentViewController: picker animated: YES completion: nil];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void) mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:SEGUE_RAW_DATA])
    {
        MSMMapObjectRawDataViewController *mapObjectRawInfoVC = segue.destinationViewController;
        mapObjectRawInfoVC.mapObject = self.mapObject;
    }
}


@end
