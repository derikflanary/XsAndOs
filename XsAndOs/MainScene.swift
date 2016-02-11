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
    private let singleButton = Button()
    private var circle1 = CircleView()
    private var circle2 = CircleView()
    
    var buttonOpened = false
    
    //MARK: - VIEW SETUP
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        layoutViews()
    }
    
    private func layoutViews(){
        
        startButton.frame = CGRectMake(20, (self.view?.center.y)! - 80, (self.view?.bounds.size.width)! - 40, 50)
        startButton.center.x = (self.view?.center.x)!
        startButton.setTitle("Multiplayer", forState: .Normal)
        startButton.addTarget(self, action: "newGamePressed", forControlEvents: .TouchUpInside)
        startButton.backgroundColor = xColor
        self.view?.addSubview(startButton)
        
        singleButton.frame = CGRectMake(20, CGRectGetMinY(startButton.frame) - 70, (self.view?.bounds.size.width)! - 40, 50)
        singleButton.setTitle("Single Player", forState: .Normal)
        singleButton.addTarget(self, action: "singlePressed", forControlEvents: .TouchUpInside)
        singleButton.backgroundColor = xColor
        self.view?.addSubview(singleButton)
    }
    
    //MARK: - BUTTON METHODS
    func newGamePressed(){
        if !buttonOpened{
            buttonOpened = true
            animateButton()
        }else{
            buttonOpened = false
            reverseButtonAnimation()
        }
    }
    
    func singlePressed(){
        print("single pressed")
        let secondScene = SingleSetupScene()
        secondScene.scaleMode = SKSceneScaleMode.AspectFill
        self.scene!.view?.presentScene(secondScene, transition: transition)
        removeViews()
    }
    
    func localPressed(){
        print("local pressed")
    }
    
    func onlinePressed(){
        print("online pressed")
    }
    
    //MARK: - SCENE CLEANUP
    override func removeViews() {
        startButton.removeFromSuperview()
        singleButton.removeFromSuperview()
        circle1.removeFromSuperview()
        circle2.removeFromSuperview()
    }
    
    //MARK: - ANIMATIONS
    
    func animateButton(){
        
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 5, options: .CurveEaseOut, animations: { () -> Void in
            self.startButton.frame.size.width = 50
            self.startButton.frame = CGRectMake((self.view?.frame.size.width)!/2 - 25, (self.view?.center.y)! - 80, 50, 50)
            self.startButton.backgroundColor = oColor
            self.startButton.setTitle("", forState: .Normal)
            
            }) { (done) -> Void in
                self.circle1 = CircleView(frame: self.startButton.frame)
                self.circle1.setTitle("Local", forState: .Normal)
                self.circle1.addTarget(self, action: "localPressed", forControlEvents: .TouchUpInside)
                self.view?.addSubview(self.circle1)
                self.circle2 = CircleView(frame: self.startButton.frame)
                self.circle2.setTitle("Online", forState: .Normal)
                self.circle2.addTarget(self, action: "onlinePressed", forControlEvents: .TouchUpInside)
                self.view?.addSubview(self.circle2)
                self.startButton.setTitle("X", forState: .Normal)
                
                UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveLinear, animations: { () -> Void in
                    self.circle2.center = CGPointMake(self.startButton.center.x, self.startButton.center.y + 60)
                    }, completion: nil)
                
                UIView.animateWithDuration(0.5, delay: 0.25, options: .CurveLinear, animations: { () -> Void in
                    self.circle1.center = CGPointMake(self.startButton.center.x, self.startButton.center.y + 30)
                    }, completion: nil)
                
                UIView.animateWithDuration(0.75, delay: 0.50, usingSpringWithDamping: 0.6, initialSpringVelocity: 5, options: .CurveEaseIn, animations: { () -> Void in
                    self.circle1.frame = CGRectMake(40, self.startButton.frame.origin.y + 60, (self.view?.frame.size.width)! - 80, 50)
                    }, completion: { (done) -> Void in})
                
                UIView.animateWithDuration(0.75, delay: 0.25, usingSpringWithDamping: 0.6, initialSpringVelocity: 5, options: .CurveEaseIn, animations: { () -> Void in
                    self.circle2.frame = CGRectMake(40, self.startButton.frame.origin.y + 120, (self.view?.frame.size.width)! - 80, 50)
                    }, completion: { (done) -> Void in})
        }
    }

    func reverseButtonAnimation(){
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: .CurveEaseOut, animations: { () -> Void in
            self.circle1.frame = self.startButton.frame
            self.circle1.titleLabel?.alpha = 0
            self.startButton.frame = self.startButton.frame
            }) { (done) -> Void in}
        
           UIView.animateWithDuration(0.5, delay: 0.25, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: .CurveEaseOut, animations: { () -> Void in
                self.circle2.frame = self.startButton.frame
                self.circle2.titleLabel?.alpha = 0
                self.circle2.titleLabel?.text = ""
                self.startButton.frame = self.startButton.frame
            }) { (done) -> Void in
                self.circle1.removeFromSuperview()
                self.circle2.removeFromSuperview()
                UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: .CurveEaseOut, animations: { () -> Void in
                    self.startButton.widthAnchor.constraintEqualToConstant(50).active = false
                    self.startButton.frame = CGRectMake(20, (self.view?.center.y)! - 80, (self.view?.bounds.size.width)! - 40, 50)
                    self.startButton.backgroundColor = xColor
                    self.startButton.setTitle("Multiplayer", forState: .Normal)
                    }) { (done) -> Void in}
                }
    }
    
}


