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

let textColor = UIColor(red: 0.78, green: 0.81, blue: 0.83, alpha: 1.0)
let oColor = UIColor(red: 0.54, green: 0.75, blue: 0.93, alpha: 1.0)
//let xColor = UIColor(red: 0.78, green: 0.36, blue: 0.35, alpha: 1.0)
let xColor = UIColor(red: 0.81, green: 0.32, blue: 0.26, alpha: 1.0)
let flint = UIColor(red: 0.49, green: 0.55, blue: 0.60, alpha: 1.0)
let backColor = UIColor(red: 0.22, green: 0.31, blue: 0.38, alpha: 1.0)
let thirdColor = UIColor(red:0.98, green:0.88, blue:0.48, alpha:1.0)
let boldFontName = "SFUIDisplay-Bold"
let mainFontName = "SFUIDisplay-Regular"
let lightFontName = "SFUIDisplay-Light"

class XandOScene: SKScene {
    
    override func didMoveToView(view: SKView) {
        backgroundColor = backColor
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedGameNotification:", name:"LoadGame", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "directGameNotification:", name:"LoadGameDirect", object: nil)
        
//        let menuButtonSize: CGSize = CGSize(width: 64.0, height: 64.0)
//        let menuButton = ExpandingMenuButton(frame: CGRect(origin: CGPointZero, size: menuButtonSize), centerImage: UIImage(named: "x")!, centerHighlightedImage: UIImage(named: "x")!)
//        menuButton.center = CGPointMake(self.view!.bounds.width/2, self.view!.bounds.height - 60.0)
//        menuButton.expandingDirection = .Bottom
//        view.addSubview(menuButton)
//        
//        let item1 = ExpandingMenuItem(size: menuButtonSize, title: "Music", image: UIImage(named: "x")!, highlightedImage: UIImage(named: "x")!, backgroundImage: UIImage(named: "x"), backgroundHighlightedImage: UIImage(named: "x")) { () -> Void in
//            // Do some action
//        }
//    
//        let item5 = ExpandingMenuItem(size: menuButtonSize, title: "Sleep", image: UIImage(named: "o")!, highlightedImage: UIImage(named: "o")!, backgroundImage: UIImage(named: "o"), backgroundHighlightedImage: UIImage(named: "o")) { () -> Void in
//            // Do some action
//        }
//        
//        menuButton.addMenuItems([item1, item5])

    }
    
    func removeViews(){
        
    }
    
    //Push Notification For Loaded Game//
    dynamic func receivedGameNotification(notification: NSNotification){
        print("notification received")
        var title = "Your turn"
        if let newGame = notification.userInfo!["newGame"]{
            if newGame as! String == "Y"{
                title = "You were invited to a new game"
            }
        }
        
        let alertController = UIAlertController(title:title, message: "load game?", preferredStyle: .Alert)
        let okayAction = UIAlertAction(title: "Okay", style: .Default) { (action) in
            let game = notification.userInfo!["game"] as! PFObject
            BoardSetupController().setupGame(game, size: self.size, completion: { (success, secondScene: MultiplayerBoard) -> Void in
                if success{
                    self.transitiontoLoadedBoard(secondScene)
                    PFInstallation.currentInstallation().badge = 0
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
                dispatch_async(dispatch_get_main_queue(),{
                    self.transitiontoLoadedBoard(secondScene)
                    PFInstallation.currentInstallation().badge = 0
                })
            }
        })
    }
    
    func transitiontoLoadedBoard(secondScene: MultiplayerBoard){
        removeViews()
        let transition = SKTransition.crossFadeWithDuration(2.0)
        self.scene?.view?.presentScene(secondScene, transition: transition)
    }

}