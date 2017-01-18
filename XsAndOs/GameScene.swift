////
////  GameScene.swift
////  XsAndOs
////
////  Created by Derik Flanary on 10/26/15.
////  Copyright (c) 2015 Derik Flanary. All rights reserved.
////
//
//import SpriteKit
//import Parse
//import ParseFacebookUtilsV4
//
//class GameScene: XandOScene {
//
//    //MARK: - PROPERTIES
//    enum ButtonPressed {
//        case fbLogIn
//        case friend
//        case currentGames
//    }
//    
//    fileprivate let fbLoginbutton = Button()
//    fileprivate let friendButton = Button()
//    fileprivate let currentGamesButton = Button()
//    fileprivate let backButton = Button()
//    var currentGames = [PFObject]()
//    fileprivate var activityIndicator = UIActivityIndicatorView()
//    
//    //MARK: - INIT
//    override init(size: CGSize) {
//        super.init(size: size)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    //MARK: - VIEW SETUP
//    override func didMove(to view: SKView) {
//        super.didMove(to: view)
//        layoutViews()
//    }
//    
//    fileprivate func layoutViews(){
//        
//        friendButton.frame = CGRect(x: (self.view?.frame.size.width)!/2 - 25, y: (self.view?.center.y)! - 80, width: 50, height: 50)
//        friendButton.center.x = (self.view?.center.x)!
//        friendButton.addTarget(self, action: #selector(GameScene.friendPressed), for: .touchUpInside)
//        friendButton.backgroundColor = oColor
//        friendButton.titleLabel?.font = UIFont(name: boldFontName, size: 32)
//        friendButton.alpha = 0
//        
//        currentGamesButton.frame = CGRect(x: (self.view?.frame.size.width)!/2 - 25, y: friendButton.frame.minY - 70, width: 50, height: 50)
//        currentGamesButton.addTarget(self, action: #selector(GameScene.currentGamesPressed), for: .touchUpInside)
//        currentGamesButton.backgroundColor = oColor
//        currentGamesButton.alpha = 0
//        currentGamesButton.titleLabel?.font = UIFont(name: boldFontName, size: 32)
//        
//        backButton.frame = CGRect(x: (self.view?.frame.size.width)!/2 - 25,y: currentGamesButton.frame.minY - 70 , width: 50, height: 50)
//        backButton.backgroundColor = xColor
//        backButton.setImage(UIImage(named: "home"), for: UIControlState())
//        backButton.imageView?.contentMode = .center
//        backButton.addTarget(self, action: #selector(GameScene.mainPressed), for: .touchUpInside)
//        backButton.tag = 20
//        self.view?.addSubview(backButton)
//        
//        fbLoginbutton.frame = CGRect(x: (self.view?.frame.size.width)!/2 - 25, y: friendButton.frame.minY + 70, width: 50, height: 50)
//        fbLoginbutton.backgroundColor = oColor
//        fbLoginbutton.titleLabel?.font = UIFont(name: boldFontName, size: 28)
//        fbLoginbutton.alpha = 0
//        fbLoginbutton.addTarget(self, action: #selector(GameScene.fbLoginPressed), for: .touchUpInside)
//        
//        if let currentUser = PFUser.current(){
//            self.view?.addSubview(friendButton)
//            self.view?.addSubview(currentGamesButton)
//            self.view?.addSubview(fbLoginbutton)
//            entryAnimation()
//            let myinstallation = PFInstallation.current()
//            myinstallation.setObject(currentUser.username!, forKey: "ownerUsername")
//            myinstallation.saveInBackground()
//            
//            if !UIApplication.shared.isRegisteredForRemoteNotifications{
//                self.showPNAlert()
//            }
//        }else{
//            self.view?.addSubview(fbLoginbutton)
//            fbEntryAnimation()
//        }
//    }
//    
//    //MARK: - ANIMATIONS
//    fileprivate func entryAnimation(){
//        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: .curveEaseOut, animations: { () -> Void in
//            self.friendButton.frame = CGRect(x: 20, y: (self.view?.center.y)! - 80, width: (self.view?.bounds.size.width)! - 40, height: 50)
//            self.currentGamesButton.frame = CGRect(x: 20, y: self.friendButton.frame.minY - 70, width: (self.view?.bounds.size.width)! - 40, height: 50)
//            self.fbLoginbutton.frame = CGRect(x: 20, y: self.friendButton.frame.minY + 140, width: (self.view?.bounds.size.width)! - 40, height: 50)
//            self.friendButton.alpha = 1
//            self.currentGamesButton.alpha = 1
//            self.fbLoginbutton.alpha = 1
//            self.fbLoginbutton.backgroundColor = flint
//            }) { (dond) -> Void in
//                self.friendButton.setTitle("Play with Friends", for: UIControlState())
//                self.currentGamesButton.setTitle("Current Games", for: UIControlState())
//                self.fbLoginbutton.setTitle("Log Out", for: UIControlState())
//        }
//    }
//    
//    fileprivate func fbEntryAnimation(){
//        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: .curveEaseOut, animations: { () -> Void in
//            self.fbLoginbutton.frame = CGRect(x: 20, y: (self.view?.center.y)! - 80, width: (self.view?.bounds.size.width)! - 40, height: 50)
//            self.fbLoginbutton.alpha = 1
//            }) { (dond) -> Void in
//                self.fbLoginbutton.setTitle("Log in with Facebook", for: UIControlState())
//        }
//
//    }
//    
//    fileprivate func exitAnimation(_ buttonPressed: ButtonPressed){
//        UIView.animate(withDuration: 0.5, animations: { () -> Void in
//            self.fbLoginbutton.alpha = 0
//            self.friendButton.alpha = 0
//            self.currentGamesButton.alpha = 0
//            self.backButton.alpha = 0
//            }, completion: { (done) -> Void in
//                switch buttonPressed{
//                case .fbLogIn:
//                    break
//                case .friend:
//                    self.transitionToFriendList()
//                case .currentGames:
//                    self.transitionToCurrentGames()
//                }
//        }) 
//    }
//    
//    //MARK: BUTTON FUNCTIONS
//    func mainPressed(){
//        buttonSoundEffect.play()
//        removeViews()
//        transitionToMainScene()
//    }
//    
//    func fbLoginPressed(){
//        buttonSoundEffect.play()
////        if let currentUser = PFUser.current(){
////            FacebookController.Singleton.sharedInstance.logoutOfFacebook({ (success) -> Void in
////                if success{
////                    dispatch_async(dispatch_get_main_queue(),{
////                        self.removeViews()
////                        let secondScene = GameScene(size: self.size)
////                        secondScene.scaleMode = SKSceneScaleMode.AspectFill
////                        self.scene!.view?.presentScene(secondScene, transition: transition)
////                    })
////                }else{
////                    self.failAlert("Logout Failed")
////                }
////            })
////        }else{
////            FacebookController.Singleton.sharedInstance.loginToFacebook { (success, friendList) -> Void in
////                if success{
////                    //update the UI here
////                    if !UIApplication.sharedApplication().isRegisteredForRemoteNotifications(){
////                        self.showPNAlert()
////                    }
////                    if let currentUser = PFUser.currentUser(){
////                        let myinstallation = PFInstallation.currentInstallation()
////                        myinstallation.setObject(currentUser.username!, forKey: "ownerUsername")
////                        myinstallation.saveInBackground()
////                    }
////                    dispatch_async(dispatch_get_main_queue(),{
////                        self.view?.addSubview(self.friendButton)
////                        self.view?.addSubview(self.currentGamesButton)
////                        self.fbLoginbutton.setTitle("Log Out", forState: .Normal)
////                        self.entryAnimation()
////                    })
////                }else{
////                    self.failAlert("Login Failed")
////                }
////            }
////        }
//    }
//    
//    fileprivate func showPNAlert(){
//        let alertController = UIAlertController(title: "Attention Please", message: "You are about to be asked to allow push notifications. By doing so your online experience will include live updating so you can play without refreshing the game. Make your decision carefully.", preferredStyle: .alert)
//        let cancelAction = UIAlertAction(title: "Okay", style: .cancel) { (action) in
//            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
//            let application = UIApplication.shared
//            application.registerUserNotificationSettings(settings)
//            application.registerForRemoteNotifications()
//        }
//        alertController.addAction(cancelAction)
//        self.view?.window?.rootViewController?.present(alertController, animated: true, completion: nil)
//    }
//    
//    func friendPressed(){
//        buttonSoundEffect.play()
//        exitAnimation(.friend)
//    }
//    
//    func currentGamesPressed(){
//        buttonSoundEffect.play()
//        exitAnimation(.currentGames)
//    }
//    
//    //MARK: - ALERTS
//    func failAlert(_ message: String){
//        let alertController = UIAlertController(title: message, message: "Check internet connection and try again.", preferredStyle: .alert)
//        let cancelAction = UIAlertAction(title: "Okay", style: .cancel) { (action) in
//        }
//        alertController.addAction(cancelAction)
//        self.view?.window?.rootViewController?.present(alertController, animated: true, completion: nil)
//    }
//    
//    //MARK: - TRANSITIONS
//    func transitionToMainScene(){
//        let mainScene = MainScene(size: self.size)
//        self.scene?.view?.presentScene(mainScene)
//    }
//    
//    fileprivate func transitionToFriendList(){
//        removeViews()
//        let secondScene = FriendListScene()
//        secondScene.scaleMode = SKSceneScaleMode.aspectFill
//        self.scene!.view?.presentScene(secondScene, transition: transition)
//    }
//    
//    func transitionToCurrentGames(){
//        removeViews()
//        let secondScene = CurrentGamesScene()
//        secondScene.scaleMode = SKSceneScaleMode.aspectFill
//        self.scene!.view?.presentScene(secondScene, transition: transition)
//    }
//    
//    //MARK: - CLEANUP
//    override func removeViews(){
//        currentGamesButton.removeFromSuperview()
//        friendButton.removeFromSuperview()
//        fbLoginbutton.removeFromSuperview()
//        backButton.removeFromSuperview()
//    }
//
//}
