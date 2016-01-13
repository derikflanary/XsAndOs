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
        xTurn = xTurnLoad
        super.startGame()
        undoButton.removeFromSuperview()
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
        
        if xLines.count > 0{
            drawLines()
        }
//        if xLinesParse.count > 0{
//            drawLoadedLines()
//        }
        turnLabel.runAction(nodeAction)
        if !xTurn{
            turnLabel.text = "O"
            nameLabel.text = oUser["name"] as? String
        }
        if gameFinished{
            finishedGameMessage()
        }
    }
    
    override func isXTurn() {
        return
    }
    
    override func animateNodes() {
        var type = "X"
        if !xTurn{
            type = "O"
        }
        startActionForNodeType(type)
    }
    
    func drawLines(){
        loopThroughLines("X")
        loopThroughLines("O")
    }
    
    func loopThroughLines(type: String){
        var linesArray = xLines
        if type == "O" {linesArray = oLines}
        for line in linesArray{
            addChild(line)
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard !gameFinished else {return}
        super.touchesBegan(touches, withEvent: event)
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
            stopActionsOnGameLayer("X")
            startActionForNodeType("O")
        }else{
            xTurn = true
            turnLabel.text = "X"
            nameLabel.text = xUser["name"] as? String
            stopActionsOnGameLayer("O")
            startActionForNodeType("X")
        }
        saveGame()
    }
    
    private func saveGame(){
        backButton.userInteractionEnabled = false
        backButton.alpha = 0.5
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
                    self.undoButton.hidden = true
//                    self.submitButton.removeFromSuperview()
                })
            }else{
                self.backButton.userInteractionEnabled = true
                self.backButton.alpha = 1
                self.showFailToSaveAlert()
                
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
            self.backButton.userInteractionEnabled = true
            self.backButton.alpha = 1
        }
        let delay = 2.0 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
//            alertController.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    private func showFailToSaveAlert(){
        let alertController = UIAlertController(title: "Move Not Sent", message: "Check your network connection and try again", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Okay", style: .Cancel) { (action) in
            self.undoLastMove()
        }
        alertController.addAction(cancelAction)
        self.view?.window?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
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
    
    override func drawLineBetweenPoints(pointA: CGPoint, pointB: CGPoint, type: String) {
        super.drawLineBetweenPoints(pointA, pointB: pointB, type: type)
        moveMade = true
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
                    PFInstallation.currentInstallation().badge = 0
                }
            })
        }else{
            super.receivedGameNotification(notification)
        }
    }
    
    override func removeViews() {
        super.removeViews()
        turnLabel.removeFromParent()
        nameLabel.removeFromParent()
//        submitButton.removeFromSuperview()
        backButton.removeFromSuperview()
    }
    
    func submitPressed(){
        print("submit pressed")
        guard moveMade else {return}
        saveGame()
    }
    
    override func undoLastMove() {
        moveMade = false
//        submitButton.removeFromSuperview()
        super.undoLastMove()
    }
}



