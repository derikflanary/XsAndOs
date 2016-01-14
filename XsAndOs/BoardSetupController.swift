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
    
    let columnAKey = "c"
    let rowAKey = "r"
    let columnBKey = "k"
    let rowBKey = "w"
    var xLinesParse : [[[String:Int]]] = []
    var oLinesParse : [[[String:Int]]] = []
    var xLines = [LineShapeNode]()
    var oLines = [LineShapeNode]()
    var xIsopin : CGFloat?
    
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
        let xLines = game.objectForKey("xLines") as! PFObject
        let oLines = game.objectForKey("oLines") as! PFObject
        secondScene = passGameDataToScene(game, secondScene: secondScene)
        secondScene = unLoadParseLines(xLines, theOLines: oLines, secondScene: secondScene)
        return secondScene
    }
    
    func unLoadParseLines(theXLines: PFObject, theOLines: PFObject, var secondScene: MultiplayerBoard) -> MultiplayerBoard{
        xLinesParse = theXLines["lines"] as! [[[String:Int]]]
        oLinesParse = theOLines["lines"] as! [[[String:Int]]]
        secondScene.xObjId = theXLines.objectId!
        secondScene.oObjId = theXLines.objectId!
        secondScene = drawLoadedLines(secondScene)
        return secondScene
    }
    
    func passGameDataToScene(game: PFObject, secondScene: MultiplayerBoard) -> MultiplayerBoard{
        secondScene.xUser = game["xTeam"] as! PFUser
        secondScene.oUser = game["oTeam"] as! PFUser
        secondScene.gameID = game.objectId!
        secondScene.xTurnLoad = game["xTurn"] as! Bool
        secondScene.gameFinished = game["finished"] as! Bool
        secondScene.scaleMode = SKSceneScaleMode.AspectFill
        xIsopin = secondScene.size.width/CGFloat(secondScene.dim)
        
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
                    secondScene = self.unLoadParseLines(theXlines!, theOLines: theOLines!, secondScene: secondScene)
                    completion(true, secondScene)
                }
            })
        }
    }
    
    func drawLoadedLines(multiBoard: MultiplayerBoard) -> MultiplayerBoard{
        loopThroughParseLines("X")
        loopThroughParseLines("O")
        multiBoard.xLines = xLines
        multiBoard.oLines = oLines
        return multiBoard
    }
    
    func loopThroughParseLines(type: String){
        var parseLines = xLinesParse
        var stroke = SKColor.redColor()
        if type == "O" {parseLines = oLinesParse; stroke = SKColor.blueColor()}
        for lineArray in parseLines{
            var firstShapeNode = LineShapeNode(columnA: 0, rowA: 0, columnB: 0, rowB: 0, team: "N")
            for line in lineArray{
                let (pointA, pointB) = pointsFromDictionary(line)
                let path = createPathAtPoints(pointA, pointB: pointB)
                if lineArray.count > 1{
                    if firstShapeNode.team == "N"{
                        firstShapeNode = LineShapeNode(columnA: line[columnAKey]!, rowA: line[rowAKey]!, columnB: line[columnBKey]!, rowB: line[rowBKey]!, team: type, path: path, color: stroke)
                    }else{
                        firstShapeNode.appendPath(path)
                        firstShapeNode.addCoordinate(line[columnAKey]!, rowA: line[rowAKey]!, columnB: line[columnBKey]!, rowB: line[rowBKey]!)
                    }
                }else{
                    firstShapeNode = LineShapeNode(columnA: line[columnAKey]!, rowA: line[rowAKey]!, columnB: line[columnBKey]!, rowB: line[rowBKey]!, team: type, path: path, color: stroke)
                }
            }
            appendLineArrays(firstShapeNode)
        }
    }
    
    private func pointsFromDictionary(line: [String:Int]) -> (CGPoint, CGPoint){
        let pointA = pointForColumn(line[columnAKey]!, row: line[rowAKey]!, size: 1)
        let pointB = pointForColumn(line[columnBKey]!, row: line[rowBKey]!, size: 1)
        return (pointA, pointB)
    }
    
    func appendLineArrays(shapeNode : LineShapeNode){
        if shapeNode.team == "X"{
            xLines.append(shapeNode)
        }else{
            oLines.append(shapeNode)
        }
    }
    
    func pointForColumn(column: Int, row: Int, size: CGFloat) -> CGPoint {
        return CGPoint(
            x: CGFloat(column) * xIsopin! + xIsopin!/2,
            y: CGFloat(row) * xIsopin! + bottomPadding)
    }

    func createPathAtPoints(pointA: CGPoint, pointB: CGPoint) -> CGPathRef{
        let ref = CGPathCreateMutable()
        CGPathMoveToPoint(ref, nil, pointA.x, pointA.y)
        CGPathAddLineToPoint(ref, nil, pointB.x, pointB.y)
        return ref
    }
    
}