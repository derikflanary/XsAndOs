//
//  MainScene.swift
//  XsAndOs
//
//  Created by Derik Flanary on 2/9/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation
import SpriteKit
import Parse
import ParseFacebookUtilsV4

class MainScene: XandOScene{
    //MARK: - PROPERTIES
    fileprivate let startButton = Button()
    fileprivate let singleButton = Button()
    fileprivate var circle1 = CircleView()
    fileprivate var circle2 = CircleView()
    fileprivate let muteButton = Button()
    fileprivate let noAdsButton = Button()
    fileprivate var pageControl: PageControl!
    fileprivate let exitButton = Button()
    fileprivate var products = [SKProduct]()
    
    var buttonOpened = false
    
    //MARK: - VIEW SETUP
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        if !UserDefaults.standard.bool(forKey: "Tutorial"){
            displayTutorial()
            UserDefaults.standard.set(true, forKey: "Tutorial")
        }else{
            layoutViews()
        }
    }
    
    
    fileprivate func layoutViews(){
        
        singleButton.frame = CGRect(x: (self.view?.frame.size.width)!/2 - 25, y: startButton.frame.minY - 70, width: 50, height: 50)
        singleButton.addTarget(self, action: #selector(MainScene.singlePressed), for: .touchUpInside)
        singleButton.addTarget(self, action: #selector(MainScene.singlePressedCancelled), for: .touchDragExit)
        singleButton.backgroundColor = xColor
        singleButton.alpha = 0
        singleButton.titleLabel?.font = UIFont(name: boldFontName, size: 32)
        self.view?.addSubview(singleButton)

        startButton.frame = CGRect(x: (self.view?.frame.size.width)!/2 - 25, y: (self.view?.center.y)! - 80, width: 50, height: 50)
        startButton.center.x = (self.view?.center.x)!
        startButton.addTarget(self, action: #selector(MainScene.multiplayerPressed), for: .touchUpInside)
        startButton.backgroundColor = xColor
        startButton.titleLabel?.font = UIFont(name: boldFontName, size: 32)
        startButton.alpha = 0
        self.view?.addSubview(startButton)
        
        muteButton.frame = CGRect(x: (self.view?.frame.size.width)!/2 - 25, y: (self.view?.frame.size.height)! - 100, width: 25, height: 25)
        muteButton.addTarget(self, action: #selector(MainScene.mutePressed), for: .touchUpInside)
        muteButton.alpha = 0
        muteButton.backgroundColor = oColor
        let status = UserDefaults.standard.value(forKey: "sound") as! String
        if status == "off"{
            muteButton.setImage(UIImage(named: "mute"), for: UIControlState())
        }else{
            muteButton.setImage(UIImage(named: "sound"), for: UIControlState())
        }
        self.view?.addSubview(muteButton)
        
        if !UserDefaults.standard.bool(forKey: "adsRemoved"){
            noAdsButton.frame = CGRect(x: (self.view?.frame.size.width)!/2 + 25, y: (self.view?.frame.size.height)! - 100, width: 25, height: 25)
            noAdsButton.addTarget(self, action: #selector(MainScene.noAdsPressed), for: .touchUpInside)
            noAdsButton.alpha = 0
            noAdsButton.backgroundColor = oColor
            noAdsButton.isEnabled = false
            noAdsButton.setImage(UIImage(named:"noAds"), for: UIControlState())
            self.view?.addSubview(noAdsButton)
            
            requestProducts()
            
            NotificationCenter.default.addObserver(self, selector: #selector(MainScene.productPurchased(_:)), name: NSNotification.Name(rawValue: IAPHelperProductPurchasedNotification), object: nil)
            
            Chartboost.showInterstitial(CBLocationMainMenu)
        }
        
        circle1.titleLabel?.font = UIFont(name: boldFontName, size: 32)
        
        entryAnimation()
    }
    
    //MARK: - BUTTON METHODS
    func multiplayerPressed(){
        buttonSoundEffect.play()
        transitionToSingleGameSetup(.local)
//        if !buttonOpened{
//            buttonOpened = true
//            animateButton()
//        }else{
//            buttonOpened = false
//            reverseButtonAnimation()
//        }
    }
    
    func singlePressed(){
        buttonSoundEffect.play()
        exitAnimation(type: .ai)
    }
    
    func singlePressedCancelled(){
        singleButton.alpha = 1
    }
    
    func localPressed(){
        print("local pressed")
        buttonSoundEffect.play()
        exitAnimation(type: .local)
        
    }
    
    
    func onlinePressed(){
        buttonSoundEffect.play()
        transitionToMultiplayerScene()
        print("online pressed")
    }
    
    func mutePressed(){
        let status = UserDefaults.standard.value(forKey: "sound") as! String
        if status == "off"{
            UserDefaults.standard.set("on", forKey: "sound")
            NotificationCenter.default.post(name: Notification.Name(rawValue: "SoundOn"), object: nil)
            muteButton.setImage(UIImage(named: "sound"), for: UIControlState())
        }else{
            UserDefaults.standard.set("off", forKey: "sound")
            NotificationCenter.default.post(name: Notification.Name(rawValue: "SoundOff"), object: nil)
            muteButton.setImage(UIImage(named: "mute"), for: UIControlState())
        }
    }
    
    func noAdsPressed(){
        let product = products[0]

        let alertController = UIAlertController(title: "", message: "Remove Ads Forever?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) -> Void in
            XOProducts.store.purchaseProduct(product: product)
        }
        let restoreAction = UIAlertAction(title: "Restore Purchase", style: .default) { (action) -> Void in
            XOProducts.store.restoreCompletedTransactions()
        }
        alertController.addAction(yesAction)
        alertController.addAction(restoreAction)
        alertController.addAction(cancelAction)
        self.view?.window?.rootViewController?.present(alertController, animated: true, completion: nil)

    }
    
    func exitPressed(){
        buttonSoundEffect.play()
        pageControl.willMoveFromView(view!)
        self.view?.removeGestureRecognizer(pageControl.panGestureRecognizer)
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.exitButton.alpha = 0
        }, completion: { (done) -> Void in
            self.transitionToMainScene()
            self.exitButton.removeFromSuperview()
            self.removeAllChildren()
        }) 
    }
    
    //MARK: - TRANSITIONS
    
    fileprivate func transitionToSingleGameSetup(_ type: SingleSetupScene.GameType){
        let secondScene = SingleSetupScene(size: self.size, type: type)
        secondScene.scaleMode = SKSceneScaleMode.aspectFill
        self.scene!.view?.presentScene(secondScene, transition: transition)
        removeViews()
    }
    
    fileprivate func transitionToFriendList(){
//        removeViews()
//        let secondScene = FriendListScene()
//        secondScene.scaleMode = SKSceneScaleMode.aspectFill
//        self.scene!.view?.presentScene(secondScene, transition: transition)
        
    }
    
    func transitionToMultiplayerScene(){
//        removeViews()
//        let secondScene = GameScene(size: self.size)
//        secondScene.scaleMode = SKSceneScaleMode.aspectFill
//        self.scene!.view?.presentScene(secondScene, transition: transition)
    }
    
    func transitionToMainScene(){
        let secondScene = MainScene(size: self.size)
        secondScene.scaleMode = SKSceneScaleMode.aspectFill
        self.scene!.view?.presentScene(secondScene, transition: transition)
    }
    
    //MARK: - SCENE CLEANUP
    override func removeViews() {
        startButton.removeFromSuperview()
        singleButton.removeFromSuperview()
        circle1.removeFromSuperview()
        circle2.removeFromSuperview()
        muteButton.removeFromSuperview()
        noAdsButton.removeFromSuperview()
    }
    
    //MARK: - ANIMATIONS
    fileprivate func entryAnimation(){
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: .curveEaseOut, animations: { () -> Void in
            self.startButton.frame = CGRect(x: 20, y: (self.view?.center.y)! - 80, width: (self.view?.bounds.size.width)! - 40, height: 50)
            self.singleButton.frame = CGRect(x: 20, y: self.startButton.frame.minY - 70, width: (self.view?.bounds.size.width)! - 40, height: 50)
            self.startButton.alpha = 1
            self.singleButton.alpha = 1
            self.muteButton.alpha = 1
            
            if !UserDefaults.standard.bool(forKey: "adsRemoved"){
                self.noAdsButton.frame = CGRect(x: (self.view?.frame.size.width)!/2 + 25, y: (self.view?.frame.size.height)! - 100, width: 50, height: 50)
                self.noAdsButton.alpha = 1
                self.muteButton.frame = CGRect(x: (self.view?.frame.size.width)!/2 - 75, y: (self.view?.frame.size.height)! - 100, width: 50, height: 50)
            }else{
                self.muteButton.frame = CGRect(x: (self.view?.frame.size.width)!/2 - 25, y: (self.view?.frame.size.height)! - 100, width: 50, height: 50)
            }
            
            }) { (dond) -> Void in
                self.startButton.setTitle("Multiplayer", for: UIControlState())
                self.singleButton.setTitle("Single Player", for: UIControlState())
        }
    }
    
    fileprivate func exitAnimation(type: SingleSetupScene.GameType ){
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.startButton.alpha = 0
            self.singleButton.alpha = 0
            self.circle1.alpha = 0
            self.circle2.alpha = 0
            self.muteButton.alpha = 0
            self.noAdsButton.alpha = 0
            }, completion: { (done) -> Void in
            self.transitionToSingleGameSetup(type)
        }) 
    }
    
    func animateButton(){
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 5, options: .curveEaseOut, animations: { () -> Void in
            self.startButton.frame.size.width = 50
            self.startButton.frame = CGRect(x: (self.view?.frame.size.width)!/2 - 25, y: (self.view?.center.y)! - 80, width: 50, height: 50)
            self.startButton.backgroundColor = oColor
            self.startButton.setTitle("", for: UIControlState())
            self.startButton.alpha = 1
            
            }) { (done) -> Void in
                self.circle1 = CircleView(frame: self.startButton.frame)
                self.circle1.setTitle("Pass & Play", for: UIControlState())
                self.circle1.addTarget(self, action: #selector(MainScene.localPressed), for: .touchUpInside)
                self.view?.addSubview(self.circle1)
                self.circle2 = CircleView(frame: self.startButton.frame)
                self.circle2.setTitle("Online", for: UIControlState())
                self.circle2.addTarget(self, action: #selector(MainScene.onlinePressed), for: .touchUpInside)
                self.view?.addSubview(self.circle2)
                self.startButton.setTitle("X", for: UIControlState())
                
                UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveLinear, animations: { () -> Void in
                    self.circle2.center = CGPoint(x: self.startButton.center.x, y: self.startButton.center.y + 60)
                    },  completion: { (done) -> Void in
                    })
                
                UIView.animate(withDuration: 0.5, delay: 0.25, options: .curveLinear, animations: { () -> Void in
                    self.circle1.center = CGPoint(x: self.startButton.center.x, y: self.startButton.center.y + 30)
                    }, completion: { (done) -> Void in
                    })

                UIView.animate(withDuration: 0.75, delay: 0.50, usingSpringWithDamping: 0.6, initialSpringVelocity: 5, options: .curveEaseIn, animations: { () -> Void in
                    self.circle1.frame = CGRect(x: 40, y: self.startButton.frame.origin.y + 60, width: (self.view?.frame.size.width)! - 80, height: 50)
                    }, completion: { (done) -> Void in
                    })
                
                UIView.animate(withDuration: 0.75, delay: 0.25, usingSpringWithDamping: 0.6, initialSpringVelocity: 5, options: .curveEaseIn, animations: { () -> Void in
                    self.circle2.frame = CGRect(x: 40, y: self.startButton.frame.origin.y + 120, width: (self.view?.frame.size.width)! - 80, height: 50)
                    }, completion: { (done) -> Void in
                    })
        }
    }

    func reverseButtonAnimation(){
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: .curveEaseOut, animations: { () -> Void in
            self.circle1.frame = self.startButton.frame
            self.circle1.titleLabel?.alpha = 0
            self.startButton.frame = self.startButton.frame
            self.startButton.alpha = 1
            }) { (done) -> Void in}
        
           UIView.animate(withDuration: 0.5, delay: 0.25, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: .curveEaseOut, animations: { () -> Void in
                self.circle2.frame = self.startButton.frame
                self.circle2.titleLabel?.alpha = 0
                self.circle2.titleLabel?.text = ""
                self.startButton.frame = self.startButton.frame
            }) { (done) -> Void in
                self.circle1.removeFromSuperview()
                self.circle2.removeFromSuperview()
                UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 5, options: .curveEaseOut, animations: { () -> Void in
                    self.startButton.widthAnchor.constraint(equalToConstant: 50).isActive = false
                    self.startButton.frame = CGRect(x: 20, y: (self.view?.center.y)! - 80, width: (self.view?.bounds.size.width)! - 40, height: 50)
                    self.startButton.backgroundColor = xColor
                    self.startButton.setTitle("Multiplayer", for: UIControlState())
                    }) { (done) -> Void in}
                }
    }
    
    //MARK: - TOUCHES
    
    //MARK: - TUTORIAL
    fileprivate func displayTutorial() {
        self.view?.viewWithTag(1000)?.removeFromSuperview()
        pageControl = PageControl(scene: self)
        addContent()
        pageControl.enable(4)
        
    }
    
    fileprivate func addContent() {
        
        exitButton.frame = CGRect(x: 20, y: (self.view?.bounds.height)! - 60, width: (self.view?.bounds.size.width)! - 40, height: 50)
        exitButton.addTarget(self, action: #selector(MainScene.exitPressed), for: .touchUpInside)
        exitButton.backgroundColor = xColor
        exitButton.setTitle("Let's Play", for: UIControlState())
        exitButton.alpha = 0
        exitButton.titleLabel?.font = UIFont(name: boldFontName, size: 32)
        self.view?.addSubview(exitButton)
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.exitButton.alpha = 1.0
        }) 
        for i in 0...3{
            var labelnode = SKLabelNode()
            labelnode.fontName = mainFontName
            labelnode.fontSize = 14
            var node = SKSpriteNode()
            if i == 0{
                labelnode = SKLabelNode(text: "Welcome to X's and O's!")
                
            }else if i == 1 || i == 2{
                node = SKSpriteNode(imageNamed: "page\(i)")
            }else{
                labelnode = SKLabelNode(text: "Have fun!")
            }
            
            let x = self.size.width / 2.0 + self.size.width * CGFloat(i)
            let y = self.size.height / 2.0 + 50
            node.position = CGPoint(x:x, y:y)
            labelnode.position = CGPoint(x: x, y: y)
            pageControl.addChild(node)
            pageControl.addChild(labelnode)
        }
    }

    //MARK: - PURCHASING
    
    fileprivate func requestProducts() {
        
        XOProducts.store.requestProductsWithCompletionHandler { success, products in
            if products.count > 0{
                self.products = products
                self.noAdsButton.isEnabled = true
                print(products)
            }
        }
    }
    
    // When a product is purchased, this notification fires, redraw the correct row
    func productPurchased(_ notification: Notification) {
        
//        let productIdentifier = notification.object as! String
        UserDefaults.standard.set(true, forKey: "adsRemoved")
        removeViews()
        transitionToMainScene()
    }
    
    
}


