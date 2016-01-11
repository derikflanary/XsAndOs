//
//  XandOScene.swift
//  XsAndOs
//
//  Created by Derik Flanary on 1/7/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation
import SpriteKit
import Parse 

class XandOScene: SKScene {
    
    override func didMoveToView(view: SKView) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedGameNotification:", name:"LoadGame", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "directGameNotification:", name:"LoadGameDirect", object: nil)
    }
    
    func removeViews(){
        
    }
    
    //Push Notification For Loaded Game//
    dynamic func receivedGameNotification(notification: NSNotification){
        print("notification received")
        var title = "Your turn"
        let newGame = notification.userInfo!["newGame"] as! Bool
        if newGame == true{
            title = "You were invited to a new game"
        }
        let alertController = UIAlertController(title:title, message: "load game?", preferredStyle: .Alert)
        let okayAction = UIAlertAction(title: "Okay", style: .Default) { (action) in
            let game = notification.userInfo!["game"] as! PFObject
            BoardSetupController().setupGame(game, size: (self.view?.frame.size)!, completion: { (success, secondScene: MultiplayerBoard) -> Void in
                if success{
                    self.transitiontoLoadedBoard(secondScene)
                }
            })
        }
        let cancelAction = UIAlertAction(title: "No", style: .Cancel) { (action) -> Void in}
        alertController.addAction(cancelAction)
        alertController.addAction(okayAction)
        self.view?.window?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
    }
    
    dynamic func directGameNotification(notification: NSNotification){
        let game = notification.userInfo!["game"] as! PFObject
        BoardSetupController().setupGame(game, size: (self.view?.frame.size)!, completion: { (success, secondScene: MultiplayerBoard) -> Void in
            if success{
                self.transitiontoLoadedBoard(secondScene)
                PFInstallation.currentInstallation().badge = 0
            }
        })
    }
    
    func transitiontoLoadedBoard(secondScene: MultiplayerBoard){
        removeViews()
        let transition = SKTransition.crossFadeWithDuration(1.5)
        dispatch_async(dispatch_get_main_queue(),{
            self.scene?.view?.presentScene(secondScene, transition: transition)
        })
    }

}