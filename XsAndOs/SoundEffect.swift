//
//  SoundEffect.swift
//  XsAndOs
//
//  Created by Derik Flanary on 2/19/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation
import AVFoundation

class SoundEffect: NSObject, AVAudioPlayerDelegate {
    
    var player = AVAudioPlayer()
        
    init(fileName: String) {
        super.init()
        
        let path = NSBundle.mainBundle().URLForResource(fileName, withExtension: "mp3")
        do{
            player = try AVAudioPlayer(contentsOfURL: path!)
            player.prepareToPlay()
            player.delegate = self
            player.rate = 2.0
        }catch let error as NSError { print(error.description)}
    }
    
    func loopPlay(){
        player.numberOfLoops = -1
        player.volume = 0.25
        player.play()
    }
    
    func play(){
        let status = NSUserDefaults.standardUserDefaults().valueForKey("sound") as! String
        guard status == "on" else {return}
        player.pause()
        player.currentTime = 0.0
        player.volume = 0.15
        player.play()
    }
    
    func mute(){
        player.volume = 0.0
    }
    
    func stop(){
        player.stop()
    }
}