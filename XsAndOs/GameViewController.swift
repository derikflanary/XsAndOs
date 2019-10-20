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
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.soundTurnedOn), name:NSNotification.Name(rawValue: "SoundOn"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.soundTurnedOff), name:NSNotification.Name(rawValue: "SoundOff"), object: nil)
        skView = self.view as! SKView
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        let overlay = StarsOverlay(frame: (self.view?.bounds)!)
        overlay.tag = 1000
        skView.addSubview(overlay)
        
        /* Set the scale mode to scale to fit the window */
        scene = MainScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        
        skView.presentScene(scene)
        
        let status = UserDefaults.standard.value(forKey: "sound") as! String
        if status == "on"{
            backgroundMusic.loopPlay()
        }
        
    }
    
    @objc func soundTurnedOn(){
        backgroundMusic.loopPlay()
        print("sound on")
    }
    
    @objc func soundTurnedOff(){
        backgroundMusic.stop()
        print("sound off")
    }
    
    
    override var shouldAutorotate : Bool {
        return false
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
}
