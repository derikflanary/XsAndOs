//
//  BoardSetupController.swift
//  XsAndOs
//
//  Created by Derik Flanary on 1/4/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation
import Parse
import SpriteKit

class BoardSetupController: NSObject {
    
    func calculateDim(var rows : Int) -> Int{
        var dim = 9
        if rows < 5{
            rows = 4
            dim = 3
        }else if rows == 5{
            dim = 5
        }else if rows == 6{
            dim = 7
        }else if rows == 7{
            dim = 9
        }else if rows >= 8{
            rows = 8
            dim = 11
        }
        dim = dim + 4
        return dim
    }

    func setupGame(game: PFObject, size: CGSize, completion: (Bool, MultiplayerBoard) -> Void){
        let dim = game["dim"] as! Int
        let rows = game["rows"] as! Int
        let xLines = game.objectForKey("xLines") as! PFObject
        let oLines = game.objectForKey("oLines") as! PFObject
        xLines.fetchIfNeededInBackgroundWithBlock { (theXlines: PFObject?,error: NSError?) -> Void in
            oLines.fetchIfNeededInBackgroundWithBlock({ (theOLines: PFObject?,error: NSError?) -> Void in
                if error != nil{
                    completion(false, MultiplayerBoard(size: size, theDim: 0, theRows: 0))
                }else{
                    let secondScene = MultiplayerBoard(size: size, theDim: dim, theRows: rows)
                    secondScene.xUser = game["xTeam"] as! PFUser
                    secondScene.oUser = game["oTeam"] as! PFUser
                    secondScene.gameID = game.objectId!
                    secondScene.xLinesParse = theXlines!["lines"] as! [[[String:Int]]]
                    secondScene.oLinesParse = theOLines!["lines"] as! [[[String:Int]]]
                    secondScene.xTurnLoad = game["xTurn"] as! Bool
                    secondScene.gameFinished = game["finished"] as! Bool
                    secondScene.xObjId = xLines.objectId!
                    secondScene.oObjId = oLines.objectId!
                    secondScene.scaleMode = SKSceneScaleMode.AspectFill
                    completion(true, secondScene)
                }
            })
        }
    }
    
}