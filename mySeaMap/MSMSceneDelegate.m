//
//  MSMSceneDelegate.m
//  mySeaMap
//

#import "MSMSceneDelegate.h"
#import "MSMAppDelegate.h"
#import "MSMCoreDataStack.h"

@implementation MSMSceneDelegate

- (MSMAppDelegate *) appDelegate
{
    return (MSMAppDelegate *)[UIApplication sharedApplication].delegate;
}

- (void) scene: (UIScene *) scene willConnectToSession: (UISceneSession *) session options: (UISceneConnectionOptions *) connectionOptions
{
    // Das Fenster und der Root-View-Controller werden über "UISceneStoryboardFile" (Info.plist) aus Main.storyboard geladen.

    // Start über eine myseamap://-URL
    for (UIOpenURLContext *context in connectionOptions.URLContexts)
    {
        [[self appDelegate] handleOpenURL: context.URL];
    }
}

- (void) scene: (UIScene *) scene openURLContexts: (NSSet<UIOpenURLContext *> *) URLContexts
{
    for (UIOpenURLContext *context in URLContexts)
    {
        [[self appDelegate] handleOpenURL: context.URL];
    }
}

- (void) sceneDidEnterBackground: (UIScene *) scene
{
    [MSMCoreDataStack save];
}

@end
