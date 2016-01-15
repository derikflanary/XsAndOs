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

let columnAKey = "c"
let rowAKey = "r"
let columnBKey = "k"
let rowBKey = "w"

class MultiplayerBoard: Board {
    
    var xTurnLoad = Bool()
    var gameID = String()
    var xUser = PFUser()
    var oUser = PFUser()
    var nameLabel = SKLabelNode()
    var gameFinished = Bool()
    var xObjId = String()
    var oObjId = String()
    var submitButton = UIButton()
    var moveMade = Bool()
    var recentMove = [[String:Int]]()
    var xLinesParse : [[[String:Int]]] = []
    var oLinesParse : [[[String:Int]]] = []
    var layersToDelete = [LineShapeLayer]()
    
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
        
        if xLinesParse.count > 0 || oLinesParse.count > 0{
            drawLoadedLines()
        }
        
        if xLines.count > 0 || xLines.count > 0{
            drawLines()
        }
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
        markIntersections("X")
        markIntersections("O")
    }
    
    func loopThroughLines(type: String){
        var linesArray = xLines
        if type == "O" {linesArray = oLines}
        for line in linesArray{
            view?.layer.addSublayer(line)
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
        print(xLines.count)
        print(oLines.count)
        let (xLineDicts, oLineDicts) = convertLinesToDictionaries()
        let coordinateDict = recentCoordinateToDict(recentCoordinates!)
        recentMove.removeAll()
        recentMove.append(coordinateDict)
        XGameController.Singleton.sharedInstance.updateGameOnParse(xTurn, xLines: xLineDicts, oLines: oLineDicts, gameId: gameID, xId: xObjId, oId: oObjId, lastMove: recentMove) { (success) -> Void in
            if success{
                print("game saved")
                let receiver = self.receiver()
                if self.oLines.count > 0{
                    if self.gameFinished{
                        self.backButton.userInteractionEnabled = true
                        self.backButton.alpha = 1
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
//        let delay = 2.0 * Double(NSEC_PER_SEC)
//        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
//        dispatch_after(time, dispatch_get_main_queue(), {
////            alertController.dismissViewControllerAnimated(true, completion: nil)
//        })
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
    
    private func receiver() -> String{
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
        if let theGame = notification.userInfo!["game"] as? PFObject{
            if theGame.objectId == gameID{
                BoardSetupController().setupGame(theGame, size: self.size, completion: { (success, secondScene: MultiplayerBoard) -> Void in
                    if success{
                        dispatch_async(dispatch_get_main_queue(),{
                            self.transitiontoLoadedBoard(secondScene)
                            PFInstallation.currentInstallation().badge = 0
                        })
                    }
                })
            }else{
                super.receivedGameNotification(notification)
            }
        }
        
    }
    
    override func removeViews() {
        super.removeViews()
        stopActionsOnGameLayer(turnString())
        turnLabel.removeFromParent()
        nameLabel.removeFromParent()
        backButton.removeFromSuperview()
        for layer in layersToDelete{
            layer.removeFromSuperlayer()
        }
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
    
//LOADING THE BOARD//
    func drawLoadedLines(){
        print(xLinesParse)
        print(oLinesParse)
        loopThroughParseLines("X")
        loopThroughParseLines("O")
        if recentMove.count > 0{
            let pointsDict = recentMove[0]
            createPathFromDictionary(pointsDict)
        }
    }
    
    func loopThroughParseLines(type: String){
        var parseLines = xLinesParse
        var stroke = UIColor.redColor().CGColor
        if type == "O" {parseLines = oLinesParse; stroke = UIColor.blueColor().CGColor}
        for lineArray in parseLines{
            var firstShapeNode = LineShapeLayer(columnA: 0, rowA: 0, columnB: 0, rowB: 0, team: "N")
            for line in lineArray{
                var (pointA, pointB) = pointsFromDictionary(line)
                pointA = convertPointToView(pointA)
                pointB = convertPointToView(pointB)
                let path = firstShapeNode.createPath(pointA: pointA, pointB: pointB)
                if lineArray.count > 1{
                    if firstShapeNode.team == "N"{
                        firstShapeNode = LineShapeLayer(columnA: line[columnAKey]!, rowA: line[rowAKey]!, columnB: line[columnBKey]!, rowB: line[rowBKey]!, team: type, path: path, color: stroke)
                    }else{
                        firstShapeNode.appendPath(path)
                        firstShapeNode.addCoordinate(line[columnAKey]!, rowA: line[rowAKey]!, columnB: line[columnBKey]!, rowB: line[rowBKey]!)
                    }
                }else{
                    firstShapeNode = LineShapeLayer(columnA: line[columnAKey]!, rowA: line[rowAKey]!, columnB: line[columnBKey]!, rowB: line[rowBKey]!, team: type, path: path, color: stroke)
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
    
    func markIntersections(type: String){
        var lineArray = xLines
        if type == "O"{
            lineArray = oLines
        }
        for line in lineArray{
            for coordinate in line.coordinates{
                let interCol = (coordinate.columnA + coordinate.columnB) / 2
                let interRow = (coordinate.rowA + coordinate.rowB) / 2
                let intersection = gridItemAtColumn(interCol, row: interRow)
                if intersection?.nodeType == NodeType.Intersection && intersection?.nodePos.ptWho == ""{
                    intersection?.nodePos.ptWho = type
                }
            }
        }
    }
    
    func recentCoordinateToDict(coordinate: RecentCoordinates) -> [String: Int]{
        let dict = [columnAKey: coordinate.columnA,
            rowAKey: coordinate.rowA,
            columnBKey: coordinate.columnB,
            rowBKey: coordinate.rowB]
        return dict
    }
    
    func createPathFromDictionary(line: [String:Int]){
        var (pointA, pointB) = pointsFromDictionary(line)
        pointA = convertPointToView(pointA)
        pointB = convertPointToView(pointB)
        let newPath = UIBezierPath()
        newPath.moveToPoint(pointA)
        newPath.addLineToPoint(pointB)
        var stroke = UIColor.redColor().CGColor
        if xTurn{
            stroke = UIColor.blueColor().CGColor
        }
        let shape = LineShapeLayer(columnA: 0, rowA: 0, columnB: 0, rowB: 0, team: "N", path: newPath.CGPath, color: stroke)
        shape.path = newPath.CGPath
        view?.layer.addSublayer(shape)
        layersToDelete.append(shape)
        animateLastMove(shape)

    }
    
    func animateLastMove(shapeLayer: LineShapeLayer){

        let animation = CABasicAnimation(keyPath: "lineWidth")
        animation.toValue = 8
        animation.duration = 0.5
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut) // animation curve is Ease Out
        animation.autoreverses = true
        animation.repeatCount = 3
        animation.delegate = self
        animation.fillMode = kCAFillModeBoth // keep to value after finishing
        animation.removedOnCompletion = false // don't remove after finishing
        shapeLayer.addAnimation(animation, forKey: animation.keyPath)

    }
}



