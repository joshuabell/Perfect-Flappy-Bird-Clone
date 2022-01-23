//
//  MMAppDelegate.m
//  Flappy Bird
//
//  Created by Joshua Bell on 2/10/14.
//

#import "MMAppDelegate.h"
//#import "Flurry.h"
//#import "Chartboost.h"

@interface MMAppDelegate () // <ChartboostDelegate>

@end

@implementation MMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    
//    NSLog( @"ifd %@", [cb deviceIdentifier]);
    // Begin a user session
//    [Chartboost startWithAppId:@"..." appSignature:@"..." delegate:self];
//    
//    Chartboost *cb = [Chartboost sharedChartboost];
//    [cb dismissChartboostView];
//    [cb cacheInterstitial:CBLocationLevelComplete];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (void)didDismissInterstitial:(NSString *)location {
    //    NSLog(@"dismissed interstitial at location %@", location);

//    [[Chartboost sharedChartboost] cacheInterstitial:CBLocationLevelComplete];
//    [Flurry logEvent:@"Dismissed Interstitial"];
}


/*
 * shouldRequestInterstitialsInFirstSession
 *
 * This sets logic to prevent interstitials from being displayed until the second startSession call
 *
 * The default is NO, meaning that it will always request & display interstitials.
 * If your app displays interstitials before the first time the user plays the game, implement this method to return NO.
 */

- (BOOL)shouldRequestInterstitialsInFirstSession {
    return YES;
}



/// Called when an interstitial has been received and cached.
//- (void)didCacheInterstitial:(CBLocation)location
//{

//    NSLog(@"did cache interstitial");
//}


- (BOOL)shouldDisplayInterstitial:(NSString *)location {
    //    NSLog(@"about to display interstitial at location %@", location);

    // For example:
    // if the user has left the main menu and is currently playing your game, return NO;

    // Otherwise return YES to display the interstitial
    return YES;
}
@end
