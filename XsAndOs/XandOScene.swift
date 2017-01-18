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
import StoreKit

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
let transition = SKTransition.crossFade(withDuration: 1)
let buttonSoundEffect = SoundEffect(fileName: "button")
let xSound = SoundEffect(fileName: "x")
let oSound = SoundEffect(fileName: "o")


class XandOScene: SKScene {
    
    override func didMove(to view: SKView) {
        if let overlay = self.view?.viewWithTag(1000){
        }else{
            let overlay = StarsOverlay(frame: (self.view?.bounds)!)
            overlay.tag = 1000
            self.view?.addSubview(overlay)
        }
        
        backgroundColor = backColor
//        NotificationCenter.default.addObserver(self, selector: #selector(XandOScene.receivedGameNotification(_:)), name:NSNotification.Name(rawValue: "LoadGame"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: "directGameNotification:", name:NSNotification.Name(rawValue: "LoadGameDirect"), object: nil)

    }
    
    func removeViews(){
        
    }
    
//    //Push Notification For Loaded Game//
//    dynamic func receivedGameNotification(_ notification: Notification){
//        print("notification received")
//        var title = "Your turn"
//        if let newGame = notification.userInfo!["newGame"]{
//            if newGame as! String == "Y"{
//                title = "You were invited to a new game"
//            }
//        }
//        
//        let alertController = UIAlertController(title:title, message: "load game?", preferredStyle: .alert)
//        let okayAction = UIAlertAction(title: "Okay", style: .default) { (action) in
//            let game = notification.userInfo!["game"] as! PFObject
//            BoardSetupController().setupGame(game, size: self.view!.frame.size, completion: { (success, secondScene: MultiplayerBoard) -> Void in
//                if success{
//                    self.transitiontoLoadedBoard(secondScene)
//                    PFInstallation.current().badge = 0
//                }
//            })
//        }
//        let cancelAction = UIAlertAction(title: "No", style: .cancel) { (action) -> Void in}
//        alertController.addAction(cancelAction)
//        alertController.addAction(okayAction)
//        self.view?.window?.rootViewController?.present(alertController, animated: true, completion: nil)
//    }
//    
//    func transitiontoLoadedBoard(_ secondScene: MultiplayerBoard){
//        removeViews()
//        let transition = SKTransition.crossFade(withDuration: 1.0)
//        self.view?.presentScene(secondScene, transition: transition)
//    }
    


}
