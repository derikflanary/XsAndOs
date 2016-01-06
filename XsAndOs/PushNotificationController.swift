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
    
    func pushNotificationNewGame(receiver: String){
        
        if let myName = PFUser.currentUser()?.valueForKey("name"){
            let pushQuery = PFInstallation.query(); //query for all devices with the receiver's username
            pushQuery?.whereKey("ownerUsername", equalTo: receiver)
            let message = "\(myName) invited you to a game" //message to be sent in notification
            let push = PFPush()  //push the notification
            push.setQuery(pushQuery)
            push.setData(["alert": message, "badge": "Increment"]) //increments the icon badge number by 1
            push.sendPushInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                if success{
                    print("Notification Pushed Successfully")
                }else{
                    print(error)
                }
            })
        }
    }
    
    func pushNotificationTheirTurn(receiver: String){
        
        if let myName = PFUser.currentUser()?.valueForKey("name"){
            let pushQuery = PFInstallation.query(); //query for all devices with the receiver's username
            pushQuery?.whereKey("ownerUsername", equalTo: receiver)
            let message = "It's your turn with \(myName)" //message to be sent in notification
            let push = PFPush()  //push the notification
            push.setQuery(pushQuery)
            push.setData(["alert": message, "badge": "Increment"]) //increments the icon badge number by 1
            push.sendPushInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                if success{
                    print("Notification Pushed Successfully")
                }else{
                    print(error)
                }
            })
        }
    }

    
    func lowerAppBadgeNumber(){
        let installation = PFInstallation.currentInstallation()
        installation.badge = installation.badge - 1
        installation.saveInBackground()
    }
    
}