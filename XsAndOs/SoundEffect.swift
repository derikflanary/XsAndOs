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
    
    var player: AVAudioPlayer?
        
    init(fileName: String) {
        super.init()
        
        guard let path = Bundle.main.url(forResource: fileName, withExtension: "mp3") else { return }
        do{
            player = try AVAudioPlayer(contentsOf: path)
            player?.prepareToPlay()
            player?.delegate = self
            player?.rate = 2.0
        }catch let error as NSError { print(error.description)}
    }
    
    func loopPlay(){
        player?.numberOfLoops = -1
        player?.volume = 0.25
        player?.play()
    }
    
    func play(){
        let status = UserDefaults.standard.value(forKey: "sound") as! String
        guard status == "on" else {return}
        player?.pause()
        player?.currentTime = 0.0
        player?.volume = 0.25
        player?.play()
    }
    
    func mute(){
        player?.volume = 0.0
    }
    
    func stop(){
        player?.stop()
    }
}
