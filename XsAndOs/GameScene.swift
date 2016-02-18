//
//  GameScene.swift
//  XsAndOs
//
//  Created by Derik Flanary on 10/26/15.
//  Copyright (c) 2015 Derik Flanary. All rights reserved.
//

import SpriteKit
import Parse
import ParseFacebookUtilsV4

class GameScene: XandOScene {

    //MARK: - PROPERTIES
    enum ButtonPressed {
        case FBLogIn
        case Friend
        case CurrentGames
    }
    
    private let fbLoginbutton = Button()
    private let friendButton = Button()
    private let currentGamesButton = Button()
    private let backButton = Button()
    var currentGames = [PFObject]()
    private var activityIndicator = UIActivityIndicatorView()
    let transition = SKTransition.crossFadeWithDuration(1)
    
    //MARK: - INIT
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - VIEW SETUP
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        layoutViews()
    }
    
    private func layoutViews(){
        
        friendButton.frame = CGRectMake((self.view?.frame.size.width)!/2 - 25, (self.view?.center.y)! - 80, 50, 50)
        friendButton.center.x = (self.view?.center.x)!
        friendButton.addTarget(self, action: "friendPressed", forControlEvents: .TouchUpInside)
        friendButton.backgroundColor = oColor
        friendButton.titleLabel?.font = UIFont(name: boldFontName, size: 32)
        friendButton.alpha = 0
        
        currentGamesButton.frame = CGRectMake((self.view?.frame.size.width)!/2 - 25, CGRectGetMinY(friendButton.frame) - 70, 50, 50)
        currentGamesButton.addTarget(self, action: "currentGamesPressed", forControlEvents: .TouchUpInside)
        currentGamesButton.backgroundColor = oColor
        currentGamesButton.alpha = 0
        currentGamesButton.titleLabel?.font = UIFont(name: boldFontName, size: 32)
        
        backButton.frame = CGRectMake((self.view?.frame.size.width)!/2 - 25,CGRectGetMinY(currentGamesButton.frame) - 70 , 50, 50)
        backButton.backgroundColor = xColor
        backButton.setImage(UIImage(named: "home"), forState: .Normal)
        backButton.imageView?.contentMode = .Center
        backButton.addTarget(self, action: "mainPressed", forControlEvents: .TouchUpInside)
        backButton.tag = 20
        self.view?.addSubview(backButton)
        
        fbLoginbutton.frame = CGRectMake((self.view?.frame.size.width)!/2 - 25, CGRectGetMinY(friendButton.frame) + 70, 50, 50)
        fbLoginbutton.backgroundColor = oColor
        fbLoginbutton.titleLabel?.font = UIFont(name: boldFontName, size: 28)
        fbLoginbutton.alpha = 0
        fbLoginbutton.addTarget(self, action: "fbLoginPressed", forControlEvents: .TouchUpInside)
        
        if let currentUser = PFUser.currentUser(){
            self.view?.addSubview(friendButton)
            self.view?.addSubview(currentGamesButton)
            self.view?.addSubview(fbLoginbutton)
            entryAnimation()
            let myinstallation = PFInstallation.currentInstallation()
            myinstallation.setObject(currentUser.username!, forKey: "ownerUsername")
            myinstallation.saveInBackground()
        }else{
            self.view?.addSubview(fbLoginbutton)
            fbEntryAnimation()
        }
    }
    
    //MARK: - ANIMATIONS
    private func entryAnimation(){
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: .CurveEaseOut, animations: { () -> Void in
            self.friendButton.frame = CGRectMake(20, (self.view?.center.y)! - 80, (self.view?.bounds.size.width)! - 40, 50)
            self.currentGamesButton.frame = CGRectMake(20, CGRectGetMinY(self.friendButton.frame) - 70, (self.view?.bounds.size.width)! - 40, 50)
            self.fbLoginbutton.frame = CGRectMake(20, CGRectGetMinY(self.friendButton.frame) + 140, (self.view?.bounds.size.width)! - 40, 50)
            self.friendButton.alpha = 1
            self.currentGamesButton.alpha = 1
            self.fbLoginbutton.alpha = 1
            self.fbLoginbutton.backgroundColor = flint
            }) { (dond) -> Void in
                self.friendButton.setTitle("Play with Friends", forState: .Normal)
                self.currentGamesButton.setTitle("Current Games", forState: .Normal)
                self.fbLoginbutton.setTitle("Log Out", forState: .Normal)
        }
    }
    
    private func fbEntryAnimation(){
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: .CurveEaseOut, animations: { () -> Void in
            self.fbLoginbutton.frame = CGRectMake(20, (self.view?.center.y)! - 80, (self.view?.bounds.size.width)! - 40, 50)
            self.fbLoginbutton.alpha = 1
            }) { (dond) -> Void in
                self.fbLoginbutton.setTitle("Log in with Facebook", forState: .Normal)
        }

    }
    
    private func exitAnimation(buttonPressed: ButtonPressed){
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.fbLoginbutton.alpha = 0
            self.friendButton.alpha = 0
            self.currentGamesButton.alpha = 0
            }) { (done) -> Void in
                switch buttonPressed{
                case .FBLogIn:
                    break
                case .Friend:
                    self.transitionToFriendList()
                case .CurrentGames:
                    self.transitionToCurrentGames()
                }
        }
    }
    
    //MARK: BUTTON FUNCTIONS
    func mainPressed(){
        removeViews()
        transitionToMainScene()
    }
    
    func fbLoginPressed(){
        if let currentUser = PFUser.currentUser(){
            FacebookController.Singleton.sharedInstance.logoutOfFacebook({ (success) -> Void in
                if success{
                    dispatch_async(dispatch_get_main_queue(),{
                        self.removeViews()
                        let secondScene = GameScene(size: self.size)
                        secondScene.scaleMode = SKSceneScaleMode.AspectFill
                        self.scene!.view?.presentScene(secondScene, transition: self.transition)
                    })
                }else{
                    self.failAlert("Logout Failed")
                }
            })
        }else{
            FacebookController.Singleton.sharedInstance.loginToFacebook { (success, friendList) -> Void in
                if success{
                    //update the UI here
                    if let currentUser = PFUser.currentUser(){
                        let myinstallation = PFInstallation.currentInstallation()
                        myinstallation.setObject(currentUser.username!, forKey: "ownerUsername")
                        myinstallation.saveInBackground()
                    }
                    dispatch_async(dispatch_get_main_queue(),{
                        self.view?.addSubview(self.friendButton)
                        self.view?.addSubview(self.currentGamesButton)
                        self.fbLoginbutton.setTitle("Log Out", forState: .Normal)
                        self.entryAnimation()
                    })
                }else{
                    self.failAlert("Login Failed")
                }
            }
        }
    }
    
    func friendPressed(){
        exitAnimation(.Friend)
    }
    
    func currentGamesPressed(){
        exitAnimation(.CurrentGames)
    }
    
    //MARK: - ALERTS
    func failAlert(message: String){
        let alertController = UIAlertController(title: message, message: "Check internet connection and try again.", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Okay", style: .Cancel) { (action) in
        }
        alertController.addAction(cancelAction)
        self.view?.window?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
    }
    
    //MARK: - TRANSITIONS
    func transitionToMainScene(){
        let mainScene = MainScene(size: self.size)
        self.scene?.view?.presentScene(mainScene)
    }
    
    private func transitionToFriendList(){
        removeViews()
        let secondScene = FriendListScene()
        secondScene.scaleMode = SKSceneScaleMode.AspectFill
        self.scene!.view?.presentScene(secondScene, transition: transition)
    }
    
    func transitionToCurrentGames(){
        removeViews()
        let secondScene = CurrentGamesScene()
        secondScene.scaleMode = SKSceneScaleMode.AspectFill
        self.scene!.view?.presentScene(secondScene, transition: transition)
    }
    
    //MARK: - CLEANUP
    override func removeViews(){
        currentGamesButton.removeFromSuperview()
        friendButton.removeFromSuperview()
        fbLoginbutton.removeFromSuperview()
        backButton.removeFromSuperview()
    }

}
