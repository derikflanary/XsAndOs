//
//  PushNotificationController.swift
//  XsAndOs
//
//  Created by Derik Flanary on 1/4/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation
import Parse

class PushNotificationController : NSObject {
    
    override init() {
        super.init()
    }
    
    func pushNotificationNewGame(receiver: String, gameID: String){
        if let myName = PFUser.currentUser()?.valueForKey("name"){
            let message = "\(myName) invited you to a game" //message to be sent in notification
            pushNotificationWithMessage(message, receiver: receiver, gameId: gameID)
        }
    }
    
    func pushNotificationTheirTurn(receiver: String, gameID: String){
        if let myName = PFUser.currentUser()?.valueForKey("name"){
            let message = "It's your turn with \(myName)" //message to be sent in notification
            pushNotificationWithMessage(message, receiver: receiver, gameId: gameID)
        }
    }
    
    func pushNotificationGameFinished(receiver: String, gameID: String){
        if let myName = PFUser.currentUser()?.valueForKey("name"){
            let message = "\(myName) just won the game." //message to be sent in notification
            pushNotificationWithMessage(message, receiver: receiver, gameId: gameID)
        }

    }
    
    private func pushNotificationWithMessage(message: String, receiver: String, gameId: String){
        let pushQuery = PFInstallation.query(); //query for all devices with the receiver's username
        pushQuery?.whereKey("ownerUsername", equalTo: receiver)
        let push = PFPush()  //push the notification
        push.setQuery(pushQuery)
        push.setData(["alert": message, "badge": "Increment", "gameId": gameId]) //increments the icon badge number by 1
        push.sendPushInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
            if success{
                print("Notification Pushed Successfully")
            }else{
                print(error)
            }
        })
    }

    func lowerAppBadgeNumber(){
        let installation = PFInstallation.currentInstallation()
        installation.badge = installation.badge - 1
        installation.saveInBackground()
    }
    
}