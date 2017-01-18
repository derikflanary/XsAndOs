////
////  PushNotificationController.swift
////  XsAndOs
////
////  Created by Derik Flanary on 1/4/16.
////  Copyright © 2016 Derik Flanary. All rights reserved.
////
//
//import Foundation
//import Parse
//
//class PushNotificationController : NSObject {
//    
//    override init() {
//        super.init()
//    }
//    
//    func pushNotificationNewGame(_ receiver: String, gameID: String){
//        if let myName = PFUser.current()?.value(forKey: "name"){
//            let message = "\(myName) invited you to a game" //message to be sent in notification
//            pushNotificationWithMessage(message, receiver: receiver, gameId: gameID, newGame: "Y")
//        }
//    }
//    
//    func pushNotificationTheirTurn(_ receiver: String, gameID: String){
//        if let myName = PFUser.current()?.value(forKey: "name"){
//            let message = "It's your turn with \(myName)" //message to be sent in notification
//            pushNotificationWithMessage(message, receiver: receiver, gameId: gameID)
//        }
//    }
//    
//    func pushNotificationGameFinished(_ receiver: String, gameID: String){
//        if let myName = PFUser.current()?.value(forKey: "name"){
//            let message = "\(myName) just won the game." //message to be sent in notification
//            pushNotificationWithMessage(message, receiver: receiver, gameId: gameID)
//        }
//    }
//    
//    fileprivate func pushNotificationWithMessage(_ message: String, receiver: String, gameId: String){
//        pushNotificationWithMessage(message, receiver: receiver, gameId: gameId, newGame: "N")
//    }
//    
//    fileprivate func pushNotificationWithMessage(_ message: String, receiver: String, gameId: String, newGame: String){
//        let pushQuery = PFInstallation.query(); //query for all devices with the receiver's username
//        pushQuery?.whereKey("ownerUsername", equalTo: receiver)
//        let push = PFPush()  //push the notification
//        push.setQuery(pushQuery as! PFQuery<PFInstallation>?)
//        push.setData(["alert": message, "badge": "Increment", "gameId": gameId, "newGame":newGame]) //increments the icon badge number by 1
//        push.sendInBackground(block: { (success: Bool, error: NSError?) -> Void in
//            if success{
//                print("Notification Pushed Successfully")
//            }else{
//                print(error)
//            }
//        })
//    }
//
//
//    func lowerAppBadgeNumber(){
//        let installation = PFInstallation.current()
//        installation.badge = installation.badge - 1
//        installation.saveInBackground()
//    }
//    
//}
