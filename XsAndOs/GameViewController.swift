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

    var scene : MainScene!
    var skView = SKView()
    let backgroundMusic = SoundEffect(fileName: "background")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "soundTurnedOn", name:"SoundOn", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "soundTurnedOff", name:"SoundOff", object: nil)
        skView = self.view as! SKView
        // Configure the view.
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        let overlay = StarsOverlay(frame: (self.view?.bounds)!)
        overlay.tag = 1000
        skView.addSubview(overlay)
        
        /* Set the scale mode to scale to fit the window */
        scene = MainScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill
        
        skView.presentScene(scene)
        
        let status = NSUserDefaults.standardUserDefaults().valueForKey("sound") as! String
        if status == "on"{
            backgroundMusic.loopPlay()
        }
        
    }
    
    func soundTurnedOn(){
        backgroundMusic.loopPlay()
        print("sound on")
    }
    
    func soundTurnedOff(){
        backgroundMusic.stop()
        print("sound off")
    }
    
    
    override func shouldAutorotate() -> Bool {
        return false
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
