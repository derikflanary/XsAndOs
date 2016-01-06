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
    
    var xTurnLoad = Bool()
    var gameID = String()
    var xUser = PFUser()
    var oUser = PFUser()
    var nameLabel = SKLabelNode()
    var xLinesParse : [[[String:Int]]] = []
    var oLinesParse : [[[String:Int]]] = []
    var gameFinished = Bool()
    var xObjId = String()
    var oObjId = String()

    override func startGame() {
        super.startGame()
        restartButton.removeFromSuperview()
        let name = xUser["name"] as! String
        nameLabel = SKLabelNode(text: name)
        nameLabel.position = CGPointMake(self.frame.width/2, turnLabel.position.y - 30)
        nameLabel.fontColor = SKColor.blackColor()
        nameLabel.fontSize = 24
        nameLabel.zPosition = 3
        self.addChild(nameLabel)
        if xLinesParse.count > 0{
            drawLoadedLines()
        }
        xTurn = xTurnLoad
        if !xTurn{
            turnLabel.text = "O"
            nameLabel.text = oUser["name"] as? String
        }
        if gameFinished{
            finishedGameMessage()
        }
        
    }
    
    func drawLoadedLines(){
        loopThroughParseLines("X")
        loopThroughParseLines("O")
    }
    
    func loopThroughParseLines(type: String){
        var parseLines = xLinesParse
        var stroke = SKColor.redColor()
        if type == "O" {parseLines = oLinesParse; stroke = SKColor.blueColor()}
        for lineArray in parseLines{
            var firstShapeNode = LineShapeNode(columnA: 0, rowA: 0, columnB: 0, rowB: 0, team: "N")
            for line in lineArray{
                let (pointA, pointB) = pointsFromDictionary(line)
                let path = createLineAtPoints(pointA, pointB: pointB)
                if lineArray.count > 1{
                    if firstShapeNode.team == "N"{
                        firstShapeNode = LineShapeNode(columnA: line["cA"]!, rowA: line["rA"]!, columnB: line["cB"]!, rowB: line["rB"]!, team: type, path: path, color: stroke)
                    }else{
                        firstShapeNode.appendPath(path)
                        firstShapeNode.addCoordinate(line["cA"]!, rowA: line["rA"]!, columnB: line["cB"]!, rowB: line["rB"]!)
                    }
                }else{
                    firstShapeNode = LineShapeNode(columnA: line["cA"]!, rowA: line["rA"]!, columnB: line["cB"]!, rowB: line["rB"]!, team: type, path: path, color: stroke)
                }
            }
            addChild(firstShapeNode)
            appendLineArrays(firstShapeNode)
        }
    }
    
    private func pointsFromDictionary(line: [String:Int]) -> (CGPoint, CGPoint){
        let pointA = pointForColumn(line["cA"]!, row: line["rA"]!, size: 1)
        let pointB = pointForColumn(line["cB"]!, row: line["rB"]!, size: 1)
        return (pointA, pointB)
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
        saveGame()
    }
    
    private func saveGame(){
        let (xLineDicts, oLineDicts) = convertLinesToDictionaries()
        XGameController.Singleton.sharedInstance.updateGameOnParse(xTurn, xLines: xLineDicts, oLines: oLineDicts, gameId: gameID, xId: xObjId, oId: oObjId) { (success) -> Void in
            if success{
                print("game saved")
                var receiver = self.oUser.username
                if self.oLines.count > 0{
                    if self.xTurn{
                        receiver = self.xUser.username
                    }
                    PushNotificationController().pushNotificationTheirTurn(receiver!, gameID: self.gameID)
                }else{
                    PushNotificationController().pushNotificationNewGame(receiver!, gameID: self.gameID)
                }
            }
        }
    }
    
    func convertLinesToDictionaries() -> ([[[String: Int]]],[[[String: Int]]] ){
        var xlineDicts = [[[String: Int]]]()
        var olineDicts = [[[String: Int]]]()
        for line in xLines{
            line.convertLinesForParse()
            xlineDicts.append(line.linesForParse)
        }
        for line in oLines{
            line.convertLinesForParse()
            olineDicts.append(line.linesForParse)
        }
        
        return (xlineDicts, olineDicts)
    }
    
    override func gameover() {
        XGameController.Singleton.sharedInstance.endGame(gameID)
        mainPressed()
    }
    
    func finishedGameMessage(){
        let alertController = UIAlertController(title: "Game Finished", message: "This game is already over. Start a new game with your friends!", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Okay", style: .Cancel) { (action) in
            self.mainPressed()
        }
        alertController.addAction(cancelAction)
        self.view?.window?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
    }
    
}



