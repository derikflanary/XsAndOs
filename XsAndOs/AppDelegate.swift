//
//  AppDelegate.swift
//  XsAndOs
//
//  Created by Derik Flanary on 10/26/15.
//  Copyright © 2015 Derik Flanary. All rights reserved.
//

import UIKit
import Parse
import Bolts
import ParseFacebookUtilsV4
import Fabric
import Crashlytics
import GameAnalytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ChartboostDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        Parse.setApplicationId("c7fI5i2vHGsajpcH7uDWjie8xLdHGhq6X6D21dBm",
            clientKey: "loGrncuqMAb1KTz99b3l1YIvw7cGwqzYjaAoHdZs")
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        Fabric.with([Crashlytics.self, GameAnalytics.self])
        
        PFInstallation.currentInstallation().badge = 0
        
        let notFirstLaunch = NSUserDefaults.standardUserDefaults().boolForKey("FirstLaunch")
        if !notFirstLaunch {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "FirstLaunch")
            NSUserDefaults.standardUserDefaults().setValue("on", forKey: "sound")
        }
        
        Chartboost.startWithAppId("56cce719c909a65118b69870", appSignature: "459d2d89d8eb862c0d5f6e77cd2d4168b71d9ec7", delegate: self)
        Chartboost.setShouldRequestInterstitialsInFirstSession(false)

        return true
    }
    
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool{
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        // Store the deviceToken in the current Installation and save it to Parse
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackground()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("failed to register for remote notifications:  (error)")
    }
    
//    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
//        print("didReceiveRemoteNotification")
//       
//        if UIApplication.sharedApplication().applicationState != UIApplicationState.Active {
//            if let gameId: String = userInfo["gameId"] as? String {
//                XGameController.Singleton.sharedInstance.fetchGameForId(gameId, completion: { (success: Bool, game: PFObject) -> Void in
//                    if success{
//                        // Do something you want when the app is active
//                        NSNotificationCenter.defaultCenter().postNotificationName("LoadGameDirect", object: nil, userInfo: ["game": game])
//                    }
//                })
//            }
//        }
//        
//    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
//        PFPush.handlePush(userInfo)
        if UIApplication.sharedApplication().applicationState == UIApplicationState.Inactive || UIApplication.sharedApplication().applicationState == UIApplicationState.Active {
           if let gameId: String = userInfo["gameId"] as? String {
            
                XGameController.Singleton.sharedInstance.fetchGameForId(gameId, completion: { (success: Bool, game: PFObject) -> Void in
                    if success{
                        if let newGame = userInfo["newGame"]{
                            if newGame as! String == "Y"{
                                NSNotificationCenter.defaultCenter().postNotificationName("LoadGame", object: nil, userInfo: ["game": game, "newGame": newGame])
                            }else{
                                NSNotificationCenter.defaultCenter().postNotificationName("LoadGame", object: nil, userInfo: ["game": game])
                            }
                        }else{
                            NSNotificationCenter.defaultCenter().postNotificationName("LoadGame", object: nil, userInfo: ["game": game])
                        }
                        completionHandler(UIBackgroundFetchResult.NewData)
                    }else{
                        completionHandler(UIBackgroundFetchResult.NoData)
                    }
                })
            }
            completionHandler(UIBackgroundFetchResult.NoData)
        }
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    

    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
        PFInstallation.currentInstallation().badge = 0
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    //MARK: - ADS
    func didInitialize(status: Bool) {
        print("chartboost did init")
    }
    
    func shouldDisplayInterstitial(location: String!) -> Bool {
        print("about to show ad at \(location)")
        return true
    }
    
    func didDisplayInterstitial(location: String!) {
        print("ad displayed")
    }
    
    func didDismissInterstitial(location: String!) {
        print("dissmissed app")
    }
    
    func didFailToLoadInterstitial(location: String!, withError error: CBLoadError) {
        switch error{
        case CBLoadError.InternetUnavailable:
            print("Failed to load Interstitial, no Internet connection !")

        case .Internal:
            print("Failed to load Interstitial, internal error !")

        case .NetworkFailure:
            print("Failed to load Interstitial, network error !")

        case .WrongOrientation:
            print("Failed to load Interstitial, wrong orientation !")

        case .TooManyConnections:
            print("Failed to load Interstitial, too many connections !")

        case .FirstSessionInterstitialsDisabled:
            print("Failed to load Interstitial, first session !")
            
        case .NoAdFound:
            print("Failed to load Interstitial, no ad found !")

        case .SessionNotStarted :
            print("Failed to load Interstitial, session not started !")
            
        case .NoLocationFound :
            print("Failed to load Interstitial, missing location parameter !")

        case .PrefetchingIncomplete:
            print("Failed to load Interstitial, prefetching still in progress !")

        case .ImpressionAlreadyVisible:
            print("Failed to load Interstitial, impression already visible !")

        default:
            print("Failed to load Interstitial, unknown error !")
        }

    }

}

