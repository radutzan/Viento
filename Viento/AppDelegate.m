//
//  AppDelegate.m
//  Viento
//
//  Created by Radu Dutzan on 12/12/14.
//  Copyright (c) 2014 Radu Dutzan. All rights reserved.
//

#import "AppDelegate.h"
#import "VTRemoteControl.h"
#import "VTMainMenuViewController.h"

@interface AppDelegate ()

@property (strong, nonatomic) VTRemoteControl *viewController;
@property (strong, nonatomic) VTExternalViewController *externalViewController;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.viewController = [VTRemoteControl sharedRemoteControl];
    self.externalViewController = [VTMainMenuViewController new];
    self.viewController.externalScreenController = self.externalViewController;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    [self checkForExternalScreenAndInitializeIfPresent];
    
    return YES;
}

- (void)setUpScreenConnectionNotificationHandlers
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self selector:@selector(handleScreenDidConnectNotification:)
                   name:UIScreenDidConnectNotification object:nil];
    [center addObserver:self selector:@selector(handleScreenDidDisconnectNotification:)
                   name:UIScreenDidDisconnectNotification object:nil];
}

- (void)handleScreenDidConnectNotification:(NSNotification*)aNotification
{
    UIScreen *newScreen = [aNotification object];
    if (!self.externalWindow) [self createExternalWindowForScreen:newScreen];
}

- (void)handleScreenDidDisconnectNotification:(NSNotification*)aNotification
{
    if (self.externalWindow) {
        // Hide and then delete the window.
        self.externalWindow.hidden = YES;
        self.externalWindow = nil;
    }
}

- (void)checkForExternalScreenAndInitializeIfPresent
{
    if ([[UIScreen screens] count] > 1) {
        // Get the screen object that represents the external display.
        UIScreen *secondScreen = [[UIScreen screens] objectAtIndex:1];
        [self createExternalWindowForScreen:secondScreen];
    }
}

- (void)createExternalWindowForScreen:(UIScreen *)screen
{
    self.externalWindow = [[UIWindow alloc] initWithFrame:screen.bounds];
    self.externalWindow.screen = screen;
    self.externalWindow.backgroundColor = [UIColor blackColor];
    self.externalViewController.view.frame = screen.bounds;
    self.externalWindow.rootViewController = self.externalViewController;
    self.externalWindow.hidden = NO;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
