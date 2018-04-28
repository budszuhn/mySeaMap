//
//  MSMAboutViewController.m
//  mySeaMap
//
//  Created by Frank Budszuhn on 06.11.13.
//  Copyright (c) 2013 Frank Budszuhn. See LICENSE.
//

#import "MSMAboutViewController.h"

@interface MSMAboutViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation MSMAboutViewController

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
    
	NSString *filePath = [[NSBundle mainBundle] pathForResource: @"about" ofType:@"html"];
	[self.webView loadRequest: [NSURLRequest requestWithURL: [NSURL fileURLWithPath: filePath]]];
}


#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	return ![[ UIApplication sharedApplication] openURL: [request URL]];
}

#pragma mark - UIPopoverPresentationControllerDelegate

- (void)prepareForPopoverPresentation:(UIPopoverPresentationController *)popoverPresentationController
{
    // This method is only called if we are presented in a popover
    [self.navigationController setNavigationBarHidden: YES];
}


@end
