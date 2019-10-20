//
//  AppDelegate.swift
//  XsAndOs
//
//  Created by Derik Flanary on 10/26/15.
//  Copyright © 2015 Derik Flanary. All rights reserved.
//

import UIKit
import Bolts
import Fabric
import Crashlytics
import GameAnalytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ChartboostDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        Fabric.with([Crashlytics.self, GameAnalytics.self])
        
        
        let notFirstLaunch = UserDefaults.standard.bool(forKey: "FirstLaunch")
        if !notFirstLaunch {
            UserDefaults.standard.set(true, forKey: "FirstLaunch")
            UserDefaults.standard.setValue("on", forKey: "sound")
        }
        
        Chartboost.start(withAppId: "56cce719c909a65118b69870", appSignature: "459d2d89d8eb862c0d5f6e77cd2d4168b71d9ec7", delegate: self)
        Chartboost.setShouldRequestInterstitialsInFirstSession(false)

        return true
    }
    
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
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
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        PFPush.handlePush(userInfo)
//        if UIApplication.shared.applicationState == UIApplicationState.inactive || UIApplication.shared.applicationState == UIApplicationState.active {
//           if let gameId: String = userInfo["gameId"] as? String {
//            
//                XGameController.Singleton.sharedInstance.fetchGameForId(gameId, completion: { (success: Bool, game: PFObject) -> Void in
//                    if success{
//                        if let newGame = userInfo["newGame"]{
//                            if newGame as! String == "Y"{
//                                NSNotificationCenter.defaultCenter().postNotificationName("LoadGame", object: nil, userInfo: ["game": game, "newGame": newGame])
//                            }else{
//                                NSNotificationCenter.defaultCenter().postNotificationName("LoadGame", object: nil, userInfo: ["game": game])
//                            }
//                        }else{
//                            NSNotificationCenter.defaultCenter().postNotificationName("LoadGame", object: nil, userInfo: ["game": game])
//                        }
//                        completionHandler(UIBackgroundFetchResult.NewData)
//                    }else{
//                        completionHandler(UIBackgroundFetchResult.NoData)
//                    }
//                })
//            }
//            completionHandler(UIBackgroundFetchResult.noData)
//        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    //MARK: - ADS
    func didInitialize(_ status: Bool) {
        print("chartboost did init")
    }
    
    func shouldDisplayInterstitial(_ location: String!) -> Bool {
        print("about to show ad at \(location)")
        return true
    }
    
    func didDisplayInterstitial(_ location: String!) {
        print("ad displayed")
    }
    
    func didDismissInterstitial(_ location: String!) {
        print("dissmissed app")
    }
    
    func didFail(toLoadInterstitial location: String!, withError error: CBLoadError) {
        switch error{
        case CBLoadError.internetUnavailable:
            print("Failed to load Interstitial, no Internet connection !")

        case .internal:
            print("Failed to load Interstitial, internal error !")

        case .networkFailure:
            print("Failed to load Interstitial, network error !")

        case .wrongOrientation:
            print("Failed to load Interstitial, wrong orientation !")

        case .tooManyConnections:
            print("Failed to load Interstitial, too many connections !")

        case .firstSessionInterstitialsDisabled:
            print("Failed to load Interstitial, first session !")
            
        case .noAdFound:
            print("Failed to load Interstitial, no ad found !")

        case .sessionNotStarted :
            print("Failed to load Interstitial, session not started !")
            
        case .noLocationFound :
            print("Failed to load Interstitial, missing location parameter !")

        case .prefetchingIncomplete:
            print("Failed to load Interstitial, prefetching still in progress !")

        case .impressionAlreadyVisible:
            print("Failed to load Interstitial, impression already visible !")

        default:
            print("Failed to load Interstitial, unknown error !")
        }

    }

}

