//
//  MultiplayerBoard.swift
//  XsAndOs
//
//  Created by Derik Flanary on 1/4/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation
import Parse
import SpriteKit

class MultiplayerBoard: Board {
    
    var xUser = PFUser()
    var oUser = PFUser()
    var nameLabel = SKLabelNode()

    override func startGame() {
        super.startGame()
        
        let name = xUser["name"] as! String
        nameLabel = SKLabelNode(text: name)
        nameLabel.position = CGPointMake(self.frame.width/2, turnLabel.position.y - 30)
        nameLabel.fontColor = SKColor.blackColor()
        nameLabel.fontSize = 24
        nameLabel.zPosition = 3
        self.addChild(nameLabel)
    }
    
    override func isCurrentUserTurn() -> Bool {
        if xTurn && xUser.username == PFUser.currentUser()?.username{
            return true
        }else if !xTurn && oUser.username == PFUser.currentUser()?.username{
            return true
        }else{
            return false
        }
    }
    
    override func switchTurns() {
        if turnLabel.text == "X"{
            xTurn = false
            turnLabel.text = "O"
            nameLabel.text = oUser["name"] as? String
        }else{
            xTurn = true
            turnLabel.text = "X"
            nameLabel.text = xUser["name"] as? String
        }
    }
}

