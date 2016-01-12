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
    var submitButton = UIButton()
    var moveMade = Bool()

    override func startGame() {
        super.startGame()
//        view!.viewWithTag(30)?.removeFromSuperview()
        restartButton.removeFromSuperview()
        let name = xUser["name"] as! String
        nameLabel = SKLabelNode(text: name)
        nameLabel.position = CGPointMake(self.frame.width/2, turnLabel.position.y - 30)
        nameLabel.fontColor = SKColor.blackColor()
        nameLabel.fontSize = 24
        nameLabel.zPosition = 3
        
        submitButton.frame = CGRectMake(0, (self.view?.frame.size.height)! - 40, (self.view?.frame.size.width)!, 30)
        submitButton.titleLabel?.font = UIFont.boldSystemFontOfSize(40)
        submitButton.setTitleColor(UIColor.darkTextColor(), forState: .Normal)
        submitButton.setTitleColor(UIColor.lightTextColor(), forState: .Highlighted)
        submitButton.setTitle("Submit Move", forState: UIControlState.Normal)
        submitButton.addTarget(self, action: "submitPressed", forControlEvents: .TouchUpInside)

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
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "receivedGameNotification:", name:"LoadGame", object: nil)
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
        if xTurn{
            xTurn = false
            turnLabel.text = "O"
            nameLabel.text = oUser["name"] as? String
        }else{
            xTurn = true
            turnLabel.text = "X"
            nameLabel.text = xUser["name"] as? String
        }
        moveMade = true
        if gameFinished{
            saveGame()
        }else{
            self.view?.addSubview(submitButton)
        }
    }
    
    private func saveGame(){
        let (xLineDicts, oLineDicts) = convertLinesToDictionaries()
        XGameController.Singleton.sharedInstance.updateGameOnParse(xTurn, xLines: xLineDicts, oLines: oLineDicts, gameId: gameID, xId: xObjId, oId: oObjId) { (success) -> Void in
            if success{
                print("game saved")
                let receiver = self.receiver()
                if self.oLines.count > 0{
                    if self.gameFinished{
                        PushNotificationController().pushNotificationGameFinished(receiver, gameID: self.gameID)
                        self.mainPressed()
                        return
                    }else{
                        PushNotificationController().pushNotificationTheirTurn(receiver, gameID: self.gameID)
                    }
                    
                }else{
                    PushNotificationController().pushNotificationNewGame(receiver, gameID: self.gameID)
                }
                dispatch_async(dispatch_get_main_queue(),{
                    self.gameSavedMessage()
                    self.moveMade = false
                    self.submitButton.removeFromSuperview()
                })
            }
        }
    }
    
    private func gameSavedMessage(){
        let alert = SKLabelNode(text: "Move Sent")
        alert.position = CGPointMake(turnLabel.position.x, turnLabel.position.y + 50)
        alert.fontColor = SKColor.redColor()
        alert.fontSize = 30
        alert.zPosition = 3
        addChild(alert)
        alert.setScale(0.1)
        alert.runAction(SKAction.scaleTo(1.0, duration: 1)) { () -> Void in
            alert.runAction(SKAction.scaleTo(0.0, duration: 1))
        }
        let delay = 2.0 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
//            alertController.dismissViewControllerAnimated(true, completion: nil)
        })
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
    
    private func receiver() -> (String){
        var receiver = self.oUser.username
        if self.xTurn{
            receiver = self.xUser.username
        }
        return receiver!
    }
    
    override func declareWinner(winningTeam: String) {
        gameFinished = true
        super.declareWinner(winningTeam)
    }
    
    override func gameover() {
        XGameController.Singleton.sharedInstance.endGame(gameID)
        let receiver = self.receiver()
        PushNotificationController().pushNotificationGameFinished(receiver, gameID: self.gameID)
        gameFinished = true
    }
    
    func finishedGameMessage(){
        let alertController = UIAlertController(title: "Game Finished", message: "This game is over. Start a new game with your friends!", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Okay", style: .Cancel) { (action) in
            self.mainPressed()
        }
        alertController.addAction(cancelAction)
        self.view?.window?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override dynamic func receivedGameNotification(notification: NSNotification) {
        let theGame = notification.userInfo!["game"] as! PFObject
        if theGame.objectId == gameID{
            BoardSetupController().setupGame(theGame, size: (self.view?.frame.size)!, completion: { (success, secondScene: MultiplayerBoard) -> Void in
                if success{
                    self.transitiontoLoadedBoard(secondScene)
                }
            })
        }else{
            super.receivedGameNotification(notification)
        }
    }
    
    override func removeViews() {
        super.removeViews()
        submitButton.removeFromSuperview()
//        scene?.removeAllChildren()
    }
    
    func submitPressed(){
        print("submit pressed")
        guard moveMade else {return}
        saveGame()
    }
    
    override func undoLastMove() {
        moveMade = false
        super.undoLastMove()
    }
}



