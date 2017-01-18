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
    
    func calculateDim(_ rows : Int) -> Int{
        var rows = rows
        var dim = 9
        switch rows{
        case 0..<5:
            rows = 4
            dim = 3
        case 5:
            dim = 5
        case 6:
            dim = 7
        case 7:
            dim = 9
        case 8..<10:
            rows = 8
            dim = 11
        default:
            rows = 7
            dim = 9
        }
        dim += 4
        return dim
    }
    
////MARK: - Load Board from Current Games
//    func updateNextSceneWithGame(_ game: PFObject, secondScene: MultiplayerBoard) -> MultiplayerBoard{
//        var secondScene = secondScene
//        secondScene = passGameDataToScene(game, secondScene: secondScene)
//        secondScene = unLoadParseLines(game, secondScene: secondScene)
//        return secondScene
//    }
//    
//    func unLoadParseLines(_ game: PFObject, secondScene: MultiplayerBoard) -> MultiplayerBoard{
//        let xLines = game.object(forKey: "xLines") as! PFObject
//        let oLines = game.object(forKey: "oLines") as! PFObject
//        secondScene.xLinesParse = xLines["lines"] as! [[[String:Int]]]
//        secondScene.oLinesParse = oLines["lines"] as! [[[String:Int]]]
//        secondScene.xObjId = xLines.objectId!
//        secondScene.oObjId = oLines.objectId!
//        return secondScene
//    }
//    
//    func passGameDataToScene(_ game: PFObject, secondScene: MultiplayerBoard) -> MultiplayerBoard{
//        secondScene.xUser = game["xTeam"] as! PFUser
//        secondScene.oUser = game["oTeam"] as! PFUser
//        secondScene.gameID = game.objectId!
//        secondScene.xTurnLoad = game["xTurn"] as! Bool
//        secondScene.gameFinished = game["finished"] as! Bool
//        secondScene.recentMove = game["lastMove"] as! [[String : Int]]
//        secondScene.scaleMode = SKSceneScaleMode.aspectFill
//        return secondScene
//    }
//
////MARK: - Load Board From Notification
//    func setupGame(_ game: PFObject, size: CGSize, completion: @escaping (Bool, MultiplayerBoard) -> Void){
//        let dim = game["dim"] as! Int
//        let rows = game["rows"] as! Int
//        let xLines = game.object(forKey: "xLines") as! PFObject
//        let oLines = game.object(forKey: "oLines") as! PFObject
//        let xUser = game["xTeam"] as! PFUser
//        var userTeam = Board.UserTeam.O
//        if xUser.objectId == PFUser.current()?.objectId{
//            userTeam = Board.UserTeam.X
//        }
//
//        xLines.fetchIfNeededInBackground { (theXlines: PFObject?,error: NSError?) -> Void in
//            oLines.fetchIfNeededInBackground(block: { (theOLines: PFObject?,error: NSError?) -> Void in
//                if error != nil{
//                    completion(false, MultiplayerBoard(size: size, theDim: 0, theRows: 0, userTeam: userTeam, aiGame: false))
//                }else{
//                    var secondScene = MultiplayerBoard(size: size, theDim: dim, theRows: rows, userTeam: userTeam, aiGame: false)
//                    
//                    secondScene = self.passGameDataToScene(game, secondScene: secondScene)
//                    secondScene.xLinesParse = theXlines!["lines"] as! [[[String:Int]]]
//                    secondScene.oLinesParse = theOLines!["lines"] as! [[[String:Int]]]
//                    secondScene.xObjId = xLines.objectId!
//                    secondScene.oObjId = oLines.objectId!
//                    completion(true, secondScene)
//                }
//            })
//        }
//    }
    
}
