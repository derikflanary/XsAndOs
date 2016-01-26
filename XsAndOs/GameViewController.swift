//
//  GameViewController.swift
//  XsAndOs
//
//  Created by Derik Flanary on 10/26/15.
//  Copyright (c) 2015 Derik Flanary. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    var scene : GameScene!
    let transition = SKTransition.crossFadeWithDuration(1)
    var menuButton : ExpandingMenuButton?
    let menuButtonSize: CGSize = CGSize(width: 64.0, height: 64.0)
    var skView = SKView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        skView = self.view as! SKView
        // Configure the view.
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill
        
        skView.presentScene(scene)
        menuButton = ExpandingMenuButton(frame: CGRect(origin: CGPointZero, size: menuButtonSize), centerImage: UIImage(named: "x")!, centerHighlightedImage: UIImage(named: "x")!)
        
        menuButton!.center = CGPointMake(self.view!.bounds.width - 60, self.view!.bounds.height - 60.0)
        menuButton!.expandingDirection = .Top
        menuButton?.tag = 1
        setupMenuButtonItems()
//        view.addSubview(menuButton!)
        
    }
    
    private func setupMenuButtonItems(){
        let item1 = ExpandingMenuItem(size: menuButtonSize, title: "New Game", image: UIImage(named: "x")!, highlightedImage: UIImage(named: "x")!, backgroundImage: UIImage(named: "x"), backgroundHighlightedImage: UIImage(named: "x")) { () -> Void in
            self.removeViewsandLayers()
            self.skView.presentScene(self.scene, transition: self.transition)
        }
        
        let item5 = ExpandingMenuItem(size: menuButtonSize, title: "Current Games", image: UIImage(named: "o")!, highlightedImage: UIImage(named: "o")!, backgroundImage: UIImage(named: "o"), backgroundHighlightedImage: UIImage(named: "o")) { () -> Void in
            let nextScene = CurrentGamesScene()
            self.scene.transitionToCurrentGames()
            
//            self.removeViewsandLayers()
        }
        
        menuButton!.addMenuItems([item1, item5])

    }
    
    private func removeViewsandLayers(){
        for subView in self.view.subviews{
                subView.removeFromSuperview()
        }
        if self.view.layer.sublayers != nil{
            for layer in self.view.layer.sublayers!{
                layer.removeFromSuperlayer()
            }
        }
        addMenuButton()
    }
    
    func addMenuButton(){
        self.view.addSubview(menuButton!)
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
