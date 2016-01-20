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
    var activityIndicator = DGActivityIndicatorView()
    
    override func startGame() {
        xTurn = xTurnLoad
        super.startGame()
        undoButton.removeFromSuperview()
        restartButton.removeFromSuperview()
        let name = xUser["name"] as! String
        nameLabel = SKLabelNode(text: name)
        nameLabel.position = CGPointMake(self.frame.width/2, turnLabel.position.y - 30)
        nameLabel.fontColor = textColor
        nameLabel.fontName = lightFontName
        nameLabel.fontSize = 24
        nameLabel.zPosition = 3
        
        self.addChild(nameLabel)
        if !xTurn{
            turnLabel.text = "O"
            turnLabel.fontColor = oColor
            nameLabel.text = oUser["name"] as? String
        }
        turnLabel.runAction(nodeAction)
        setupBoard()
    }
    
    func setupBoard(){
        if xLinesParse.count > 0 || oLinesParse.count > 0{
            drawLoadedLines()
        }
        if xLines.count > 0 || xLines.count > 0{
            drawLines()
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
            turnLabel.fontColor = oColor
            nameLabel.text = oUser["name"] as? String
            stopActionsOnGameLayer("X")
            startActionForNodeType("O")
        }else{
            xTurn = true
            turnLabel.text = "X"
            turnLabel.fontColor = xColor
            nameLabel.text = xUser["name"] as? String
            stopActionsOnGameLayer("O")
            startActionForNodeType("X")
        }
        guard moveMade else {return}
        saveGame()
    }
    
    private func saveGame(){
        let dimView = UIView(frame: (view?.frame)!)
        dimBackground(dimView)
        backButton.userInteractionEnabled = false
        backButton.alpha = 0.5
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
                        self.gameSavedMessage(dimView)
                        return
                    }else{
                        PushNotificationController().pushNotificationTheirTurn(receiver, gameID: self.gameID)
                    }
                }else{
                    PushNotificationController().pushNotificationNewGame(receiver, gameID: self.gameID)
                }
                dispatch_async(dispatch_get_main_queue(),{
                    self.gameSavedMessage(dimView)
                    self.moveMade = false
                })
            }else{
                self.backButton.userInteractionEnabled = true
                self.backButton.alpha = 1
                self.showFailToSaveAlert()
                self.unDimBackground(dimView)
            }
        }
    }
    
    private func gameSavedMessage(dimView: UIView){
        let alert = SKLabelNode(text: "Move Sent")
        alert.position = CGPointMake(turnLabel.position.x, turnLabel.position.y + 50)
        alert.fontColor = thirdColor
        alert.fontName = boldFontName
        alert.fontSize = 50
        alert.zPosition = 3
        addChild(alert)
        alert.setScale(0.1)
        alert.runAction(SKAction.scaleTo(1.0, duration: 1)) { () -> Void in
            alert.runAction(SKAction.scaleTo(0.0, duration: 1))
            self.backButton.userInteractionEnabled = true
            self.backButton.alpha = 1
            self.unDimBackground(dimView)
        }
    }
    
    func dimBackground(dimView: UIView){
        activityIndicator = DGActivityIndicatorView(type: DGActivityIndicatorAnimationType .BallZigZagDeflect, tintColor: textColor, size: 200)
        activityIndicator.frame = CGRectMake((view?.frame.size.width)!/2 - 25, (view?.frame.size.height)!/2, 50.0, 50.0);
        dimView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        dimView.backgroundColor = UIColor.darkGrayColor()
        dimView.alpha = 0
        view?.addSubview(dimView)
        UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseOut, animations: { () -> Void in
            dimView.alpha = 0.6
            }) { (done) -> Void in
        }
    }
    
    func unDimBackground(dimView: UIView){
        UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveEaseOut, animations: { () -> Void in
            dimView.alpha = 0.0
            self.activityIndicator.alpha = 0.0
            }) { (done) -> Void in
                dimView.removeFromSuperview()
        }
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
        mainPressed()
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
//                            self.transitiontoLoadedBoard(secondScene)
                            self.loadMove(secondScene)
                            PFInstallation.currentInstallation().badge = 0
                        })
                    }
                })
            }else{
                super.receivedGameNotification(notification)
            }
        }
    }
    
    func loadMove(loadedScene: MultiplayerBoard){
        xLinesParse = loadedScene.xLinesParse
        oLinesParse = loadedScene.oLinesParse
        recentMove = loadedScene.recentMove
        xTurn = loadedScene.xTurnLoad
        removeLines()
        drawLoadedLines()
        drawLines()
        updateTurnLabel()
        gameFinished = loadedScene.gameFinished
        if gameFinished{
            finishedGameMessage()
        }
    }
    
    override func removeLines() {
        super.removeLines()
        xLines.removeAll()
        oLines.removeAll()
    }
    
    func updateTurnLabel(){
        if !xTurn{
            turnLabel.text = "O"
            nameLabel.text = oUser["name"] as? String
            turnLabel.fontColor = oColor
            stopActionsOnGameLayer("X")
            startActionForNodeType("O")
        }else{
            turnLabel.text = "X"
            nameLabel.text = xUser["name"] as? String
            turnLabel.fontColor = xColor
            stopActionsOnGameLayer("O")
            startActionForNodeType("X")
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
        var stroke = xColor.CGColor
        if type == "O" {parseLines = oLinesParse; stroke = oColor.CGColor}
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
        var stroke = xColor.CGColor
        if xTurn{
            stroke = oColor.CGColor
        }
        let shape = LineShapeLayer(columnA: 0, rowA: 0, columnB: 0, rowB: 0, team: "N", path: newPath.CGPath, color: stroke)
        shape.path = newPath.CGPath
        view?.layer.addSublayer(shape)
        layersToDelete.append(shape)
        animateLastMove(shape)

    }
    
    func animateLastMove(shapeLayer: LineShapeLayer){

        let animation = CABasicAnimation(keyPath: "lineWidth")
        animation.toValue = 6
        animation.duration = 0.5
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut) // animation curve is Ease Out
        animation.autoreverses = true
        animation.repeatCount = 4
        animation.delegate = self
        animation.fillMode = kCAFillModeBoth // keep to value after finishing
        animation.removedOnCompletion = false // don't remove after finishing
        shapeLayer.addAnimation(animation, forKey: animation.keyPath)

    }
}



