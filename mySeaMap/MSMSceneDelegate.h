//
//  MSMSceneDelegate.h
//  mySeaMap
//
//  Ab dem iOS-27-SDK verlangt Apple den Scene-basierten Lebenszyklus (UIScene).
//  Das Fenster wird jetzt hier verwaltet statt im App-Delegate.
//

#import <UIKit/UIKit.h>

@interface MSMSceneDelegate : UIResponder <UIWindowSceneDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
