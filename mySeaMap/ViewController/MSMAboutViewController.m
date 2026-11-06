//
//  MSMAboutViewController.m
//  mySeaMap
//
//  Created by Frank Budszuhn on 06.11.13.
//  Copyright (c) 2013 Frank Budszuhn. See LICENSE.
//
//  2026: UIWebView (von Apple entfernt) durch WKWebView ersetzt.
//

@import WebKit;

#import "MSMAboutViewController.h"

@interface MSMAboutViewController () <WKNavigationDelegate>

@property (strong, nonatomic) WKWebView *webView;

@end

@implementation MSMAboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    WKWebView *webView = [[WKWebView alloc] initWithFrame: self.view.bounds configuration: [[WKWebViewConfiguration alloc] init]];
    webView.navigationDelegate = self;
    webView.translatesAutoresizingMaskIntoConstraints = NO;
    webView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview: webView];

    UILayoutGuide *guide = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints: @[
        [webView.leadingAnchor constraintEqualToAnchor: self.view.leadingAnchor],
        [webView.trailingAnchor constraintEqualToAnchor: self.view.trailingAnchor],
        [webView.topAnchor constraintEqualToAnchor: guide.topAnchor],
        [webView.bottomAnchor constraintEqualToAnchor: self.view.bottomAnchor]
    ]];
    self.webView = webView;

    NSURL *fileURL = [[NSBundle mainBundle] URLForResource: @"about" withExtension: @"html"];
    if (fileURL)
    {
        [self.webView loadFileURL: fileURL allowingReadAccessToURL: [fileURL URLByDeletingLastPathComponent]];
    }
}


#pragma mark - WKNavigationDelegate

// Links aus der Info-Seite werden in Safari bzw. der zuständigen App geöffnet
- (void) webView: (WKWebView *) webView decidePolicyForNavigationAction: (WKNavigationAction *) navigationAction decisionHandler: (void (^)(WKNavigationActionPolicy)) decisionHandler
{
    NSURL *url = navigationAction.request.URL;

    if (navigationAction.navigationType == WKNavigationTypeLinkActivated && url && ! url.isFileURL)
    {
        [[UIApplication sharedApplication] openURL: url options: @{} completionHandler: nil];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }

    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark - UIPopoverPresentationControllerDelegate

- (void)prepareForPopoverPresentation:(UIPopoverPresentationController *)popoverPresentationController
{
    // This method is only called if we are presented in a popover
    [self.navigationController setNavigationBarHidden: YES];
}


@end
