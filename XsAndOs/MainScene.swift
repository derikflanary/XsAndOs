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
    private let startButton = Button()
    private let singleButton = SButton()
    private var circle1 = CircleView()
    private var circle2 = CircleView()
    private let muteButton = Button()
    private let noAdsButton = Button()
    private var pageControl: PageControl!
    private let exitButton = Button()
    private var products = [SKProduct]()
    
    var buttonOpened = false
    
    //MARK: - VIEW SETUP
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        
        if !NSUserDefaults.standardUserDefaults().boolForKey("Tutorial"){
            displayTutorial()
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "Tutorial")
        }else{
            layoutViews()
        }

    }
    
    
    private func layoutViews(){
        
        singleButton.frame = CGRectMake((self.view?.frame.size.width)!/2 - 25, CGRectGetMinY(startButton.frame) - 70, 50, 50)
        singleButton.addTarget(self, action: "singlePressed", forControlEvents: .TouchUpInside)
        singleButton.addTarget(self, action: "singlePressedCancelled", forControlEvents: .TouchDragExit)
        singleButton.backgroundColor = xColor
        singleButton.alpha = 0
        singleButton.titleLabel?.font = UIFont(name: boldFontName, size: 32)
        self.view?.addSubview(singleButton)

        startButton.frame = CGRectMake((self.view?.frame.size.width)!/2 - 25, (self.view?.center.y)! - 80, 50, 50)
        startButton.center.x = (self.view?.center.x)!
        startButton.addTarget(self, action: "multiplayerPressed", forControlEvents: .TouchUpInside)
        startButton.backgroundColor = xColor
        startButton.titleLabel?.font = UIFont(name: boldFontName, size: 32)
        startButton.alpha = 0
        self.view?.addSubview(startButton)
        
        muteButton.frame = CGRectMake((self.view?.frame.size.width)!/2 - 25, (self.view?.frame.size.height)! - 100, 25, 25)
        muteButton.addTarget(self, action: "mutePressed", forControlEvents: .TouchUpInside)
        muteButton.alpha = 0
        muteButton.backgroundColor = oColor
        let status = NSUserDefaults.standardUserDefaults().valueForKey("sound") as! String
        if status == "off"{
            muteButton.setImage(UIImage(named: "mute"), forState: .Normal)
        }else{
            muteButton.setImage(UIImage(named: "sound"), forState: .Normal)
        }
        self.view?.addSubview(muteButton)
        
        if !NSUserDefaults.standardUserDefaults().boolForKey("adsRemoved"){
            noAdsButton.frame = CGRectMake((self.view?.frame.size.width)!/2 + 25, (self.view?.frame.size.height)! - 100, 25, 25)
            noAdsButton.addTarget(self, action: "noAdsPressed", forControlEvents: .TouchUpInside)
            noAdsButton.alpha = 0
            noAdsButton.backgroundColor = oColor
            noAdsButton.enabled = false
            noAdsButton.setImage(UIImage(named:"noAds"), forState: .Normal)
            self.view?.addSubview(noAdsButton)
            
            requestProducts()
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "productPurchased:", name: IAPHelperProductPurchasedNotification, object: nil)
            
            Chartboost.showInterstitial(CBLocationMainMenu)
        }
        
        circle1.titleLabel?.font = UIFont(name: boldFontName, size: 32)
        
        entryAnimation()
    }
    
    //MARK: - BUTTON METHODS
    func multiplayerPressed(){
        buttonSoundEffect.play()
        if !buttonOpened{
            buttonOpened = true
            animateButton()
        }else{
            buttonOpened = false
            reverseButtonAnimation()
        }
    }
    
    func singlePressed(){
        buttonSoundEffect.play()
        exitAnimation()
    }
    
    func singlePressedCancelled(){
        singleButton.alpha = 1
    }
    
    func localPressed(){
        print("local pressed")
        buttonSoundEffect.play()
        transitionToSingleGameSetup(.Local)
        
    }
    
    func onlinePressed(){
        buttonSoundEffect.play()
        transitionToMultiplayerScene()
        print("online pressed")
    }
    
    func mutePressed(){
        let status = NSUserDefaults.standardUserDefaults().valueForKey("sound") as! String
        if status == "off"{
            NSUserDefaults.standardUserDefaults().setObject("on", forKey: "sound")
            NSNotificationCenter.defaultCenter().postNotificationName("SoundOn", object: nil)
            muteButton.setImage(UIImage(named: "sound"), forState: .Normal)
        }else{
            NSUserDefaults.standardUserDefaults().setObject("off", forKey: "sound")
            NSNotificationCenter.defaultCenter().postNotificationName("SoundOff", object: nil)
            muteButton.setImage(UIImage(named: "mute"), forState: .Normal)
        }
    }
    
    func noAdsPressed(){
        let product = products[0]
        XOProducts.store.purchaseProduct(product)
    }
    
    func exitPressed(){
        buttonSoundEffect.play()
        pageControl.willMoveFromView(view!)
        self.view?.removeGestureRecognizer(pageControl.panGestureRecognizer)
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.exitButton.alpha = 0
        }) { (done) -> Void in
            self.transitionToMainScene()
            self.exitButton.removeFromSuperview()
            self.removeAllChildren()
        }
    }
    
    //MARK: - TRANSITIONS
    
    private func transitionToSingleGameSetup(type: SingleSetupScene.GameType){
        let secondScene = SingleSetupScene(size: self.size, type: type)
        secondScene.scaleMode = SKSceneScaleMode.AspectFill
        self.scene!.view?.presentScene(secondScene, transition: transition)
        removeViews()
    }
    
    private func transitionToFriendList(){
        removeViews()
        let secondScene = FriendListScene()
        secondScene.scaleMode = SKSceneScaleMode.AspectFill
        self.scene!.view?.presentScene(secondScene, transition: transition)
        
    }
    
    func transitionToMultiplayerScene(){
        removeViews()
        let secondScene = GameScene(size: self.size)
        secondScene.scaleMode = SKSceneScaleMode.AspectFill
        self.scene!.view?.presentScene(secondScene, transition: transition)
    }
    
    func transitionToMainScene(){
        let secondScene = MainScene(size: self.size)
        secondScene.scaleMode = SKSceneScaleMode.AspectFill
        self.scene!.view?.presentScene(secondScene, transition: transition)
    }
    
    //MARK: - SCENE CLEANUP
    override func removeViews() {
        startButton.removeFromSuperview()
        singleButton.removeFromSuperview()
        circle1.removeFromSuperview()
        circle2.removeFromSuperview()
        muteButton.removeFromSuperview()
    }
    
    //MARK: - ANIMATIONS
    private func entryAnimation(){
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: .CurveEaseOut, animations: { () -> Void in
            self.startButton.frame = CGRectMake(20, (self.view?.center.y)! - 80, (self.view?.bounds.size.width)! - 40, 50)
            self.singleButton.frame = CGRectMake(20, CGRectGetMinY(self.startButton.frame) - 70, (self.view?.bounds.size.width)! - 40, 50)
            self.startButton.alpha = 1
            self.singleButton.alpha = 1
            self.muteButton.alpha = 1
            
            if !NSUserDefaults.standardUserDefaults().boolForKey("adsRemoved"){
                self.noAdsButton.frame = CGRectMake((self.view?.frame.size.width)!/2 + 25, (self.view?.frame.size.height)! - 100, 50, 50)
                self.noAdsButton.alpha = 1
                self.muteButton.frame = CGRectMake((self.view?.frame.size.width)!/2 - 75, (self.view?.frame.size.height)! - 100, 50, 50)
            }else{
                self.muteButton.frame = CGRectMake((self.view?.frame.size.width)!/2 - 25, (self.view?.frame.size.height)! - 100, 50, 50)
            }
            
            }) { (dond) -> Void in
                self.startButton.setTitle("Multiplayer", forState: .Normal)
                self.singleButton.setTitle("Single Player", forState: .Normal)
        }
    }
    
    private func exitAnimation(){
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.startButton.alpha = 0
            self.singleButton.alpha = 0
            self.circle1.alpha = 0
            self.circle2.alpha = 0
            self.muteButton.alpha = 0
            }) { (done) -> Void in
            self.transitionToSingleGameSetup(.AI)
        }
    }
    
    func animateButton(){
        
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 5, options: .CurveEaseOut, animations: { () -> Void in
            self.startButton.frame.size.width = 50
            self.startButton.frame = CGRectMake((self.view?.frame.size.width)!/2 - 25, (self.view?.center.y)! - 80, 50, 50)
            self.startButton.backgroundColor = oColor
            self.startButton.setTitle("", forState: .Normal)
            self.startButton.alpha = 1
            
            }) { (done) -> Void in
                self.circle1 = CircleView(frame: self.startButton.frame)
                self.circle1.setTitle("Pass & Play", forState: .Normal)
                self.circle1.addTarget(self, action: "localPressed", forControlEvents: .TouchUpInside)
                self.view?.addSubview(self.circle1)
                self.circle2 = CircleView(frame: self.startButton.frame)
                self.circle2.setTitle("Online", forState: .Normal)
                self.circle2.addTarget(self, action: "onlinePressed", forControlEvents: .TouchUpInside)
                self.view?.addSubview(self.circle2)
                self.startButton.setTitle("X", forState: .Normal)
                
                UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveLinear, animations: { () -> Void in
                    self.circle2.center = CGPointMake(self.startButton.center.x, self.startButton.center.y + 60)
                    },  completion: { (done) -> Void in
                    })
                
                UIView.animateWithDuration(0.5, delay: 0.25, options: .CurveLinear, animations: { () -> Void in
                    self.circle1.center = CGPointMake(self.startButton.center.x, self.startButton.center.y + 30)
                    }, completion: { (done) -> Void in
                    })

                UIView.animateWithDuration(0.75, delay: 0.50, usingSpringWithDamping: 0.6, initialSpringVelocity: 5, options: .CurveEaseIn, animations: { () -> Void in
                    self.circle1.frame = CGRectMake(40, self.startButton.frame.origin.y + 60, (self.view?.frame.size.width)! - 80, 50)
                    }, completion: { (done) -> Void in
                    })
                
                UIView.animateWithDuration(0.75, delay: 0.25, usingSpringWithDamping: 0.6, initialSpringVelocity: 5, options: .CurveEaseIn, animations: { () -> Void in
                    self.circle2.frame = CGRectMake(40, self.startButton.frame.origin.y + 120, (self.view?.frame.size.width)! - 80, 50)
                    }, completion: { (done) -> Void in
                    })
        }
    }

    func reverseButtonAnimation(){
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: .CurveEaseOut, animations: { () -> Void in
            self.circle1.frame = self.startButton.frame
            self.circle1.titleLabel?.alpha = 0
            self.startButton.frame = self.startButton.frame
            self.startButton.alpha = 1
            }) { (done) -> Void in}
        
           UIView.animateWithDuration(0.5, delay: 0.25, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: .CurveEaseOut, animations: { () -> Void in
                self.circle2.frame = self.startButton.frame
                self.circle2.titleLabel?.alpha = 0
                self.circle2.titleLabel?.text = ""
                self.startButton.frame = self.startButton.frame
            }) { (done) -> Void in
                self.circle1.removeFromSuperview()
                self.circle2.removeFromSuperview()
                UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 5, options: .CurveEaseOut, animations: { () -> Void in
                    self.startButton.widthAnchor.constraintEqualToConstant(50).active = false
                    self.startButton.frame = CGRectMake(20, (self.view?.center.y)! - 80, (self.view?.bounds.size.width)! - 40, 50)
                    self.startButton.backgroundColor = xColor
                    self.startButton.setTitle("Multiplayer", forState: .Normal)
                    }) { (done) -> Void in}
                }
    }
    
    //MARK: - TOUCHES
    
    //MARK: - TUTORIAL
    private func displayTutorial() {
        self.view?.viewWithTag(1000)?.removeFromSuperview()
        pageControl = PageControl(scene: self)
        addContent()
        pageControl.enable(4)
        
    }
    
    private func addContent() {
        
        exitButton.frame = CGRectMake(20, (self.view?.bounds.height)! - 60, (self.view?.bounds.size.width)! - 40, 50)
        exitButton.addTarget(self, action: "exitPressed", forControlEvents: .TouchUpInside)
        exitButton.backgroundColor = xColor
        exitButton.setTitle("Let's Play", forState: .Normal)
        exitButton.alpha = 0
        exitButton.titleLabel?.font = UIFont(name: boldFontName, size: 32)
        self.view?.addSubview(exitButton)
        UIView.animateWithDuration(0.5) { () -> Void in
            self.exitButton.alpha = 1.0
        }
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
    
    private func requestProducts() {
        
        XOProducts.store.requestProductsWithCompletionHandler { success, products in
            if products.count > 0{
                self.products = products
                self.noAdsButton.enabled = true
                print(products)
            }
        }
    }
    
    // When a product is purchased, this notification fires, redraw the correct row
    func productPurchased(notification: NSNotification) {
        
//        let productIdentifier = notification.object as! String
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "adsRemoved")
    }
    
    
}


