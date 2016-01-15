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
//Load Board from Current Games//
    func updateNextSceneWithGame(game: PFObject, var secondScene: MultiplayerBoard) -> MultiplayerBoard{
        secondScene = passGameDataToScene(game, secondScene: secondScene)
        secondScene = unLoadParseLines(game, secondScene: secondScene)
        return secondScene
    }
    
    func unLoadParseLines(game: PFObject, secondScene: MultiplayerBoard) -> MultiplayerBoard{
        let xLines = game.objectForKey("xLines") as! PFObject
        let oLines = game.objectForKey("oLines") as! PFObject
        secondScene.xLinesParse = xLines["lines"] as! [[[String:Int]]]
        secondScene.oLinesParse = oLines["lines"] as! [[[String:Int]]]
        secondScene.xObjId = xLines.objectId!
        secondScene.oObjId = oLines.objectId!
        return secondScene
    }
    
    func passGameDataToScene(game: PFObject, secondScene: MultiplayerBoard) -> MultiplayerBoard{
        secondScene.xUser = game["xTeam"] as! PFUser
        secondScene.oUser = game["oTeam"] as! PFUser
        secondScene.gameID = game.objectId!
        secondScene.xTurnLoad = game["xTurn"] as! Bool
        secondScene.gameFinished = game["finished"] as! Bool
        secondScene.recentMove = game["lastMove"] as! [[String : Int]]
        secondScene.scaleMode = SKSceneScaleMode.AspectFill
        return secondScene
        }

//Load Board From Notification//
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
                    var secondScene = MultiplayerBoard(size: size, theDim: dim, theRows: rows)
                    
                    secondScene = self.passGameDataToScene(game, secondScene: secondScene)
                    secondScene.xLinesParse = theXlines!["lines"] as! [[[String:Int]]]
                    secondScene.oLinesParse = theOLines!["lines"] as! [[[String:Int]]]
                    secondScene.xObjId = xLines.objectId!
                    secondScene.oObjId = oLines.objectId!
                    completion(true, secondScene)
                }
            })
        }
    }
    
//    func drawLoadedLines(multiBoard: MultiplayerBoard) -> MultiplayerBoard{
//        xIsopin = multiBoard.xIsopin
//        loopThroughParseLines("X", scene: multiBoard)
//        loopThroughParseLines("O", scene: multiBoard)
//        multiBoard.xLines = xLines
//        multiBoard.oLines = oLines
//        return multiBoard
//    }
//    
//    func loopThroughParseLines(type: String, scene: MultiplayerBoard){
//        var parseLines = xLinesParse
//        var stroke = UIColor.redColor().CGColor
//        if type == "O" {parseLines = oLinesParse; stroke = UIColor.blueColor().CGColor}
//        for lineArray in parseLines{
//            var firstShapeNode = LineShapeLayer(columnA: 0, rowA: 0, columnB: 0, rowB: 0, team: "N")
//            for line in lineArray{
//                var (pointA, pointB) = pointsFromDictionary(line)
//                pointA = scene.convertPointToView(pointA)
//                pointB = scene.convertPointToView(pointB)
//                let path = createPathAtPoints(pointA, pointB: pointB)
//                if lineArray.count > 1{
//                    if firstShapeNode.team == "N"{
//                        firstShapeNode = LineShapeLayer(columnA: line[columnAKey]!, rowA: line[rowAKey]!, columnB: line[columnBKey]!, rowB: line[rowBKey]!, team: type, path: path, color: stroke)
//                    }else{
//                        firstShapeNode.appendPath(path)
//                        firstShapeNode.addCoordinate(line[columnAKey]!, rowA: line[rowAKey]!, columnB: line[columnBKey]!, rowB: line[rowBKey]!)
//                    }
//                }else{
//                    firstShapeNode = LineShapeLayer(columnA: line[columnAKey]!, rowA: line[rowAKey]!, columnB: line[columnBKey]!, rowB: line[rowBKey]!, team: type, path: path, color: stroke)
//                }
//            }
//            appendLineArrays(firstShapeNode)
//        }
//    }
//    
//    private func pointsFromDictionary(line: [String:Int]) -> (CGPoint, CGPoint){
//        let pointA = pointForColumn(line[columnAKey]!, row: line[rowAKey]!, size: 1)
//        let pointB = pointForColumn(line[columnBKey]!, row: line[rowBKey]!, size: 1)
//        return (pointA, pointB)
//    }
//    
//    func appendLineArrays(shapeNode : LineShapeLayer){
//        if shapeNode.team == "X"{
//            xLines.append(shapeNode)
//        }else{
//            oLines.append(shapeNode)
//        }
//    }
//    
//    func pointForColumn(column: Int, row: Int, size: CGFloat) -> CGPoint {
//        return CGPoint(
//            x: CGFloat(column) * xIsopin! + xIsopin!/2,
//            y: CGFloat(row) * xIsopin! + bottomPadding)
//    }
//
//    func createPathAtPoints(pointA: CGPoint, pointB: CGPoint) -> CGPathRef{
//        let ref = CGPathCreateMutable()
//        CGPathMoveToPoint(ref, nil, pointA.x, pointA.y)
//        CGPathAddLineToPoint(ref, nil, pointB.x, pointB.y)
//        return ref
//    }
//    
}