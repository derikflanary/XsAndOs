////
////  MultiplayerBoard.swift
////  XsAndOs
////
////  Created by Derik Flanary on 1/4/16.
////  Copyright © 2016 Derik Flanary. All rights reserved.
////
//
//import Foundation
//import Parse
//import SpriteKit
//
//let columnAKey = "c"
//let rowAKey = "r"
//let columnBKey = "k"
//let rowBKey = "w"
//
//class MultiplayerBoard: Board {
//    
//    var xTurnLoad = Bool()
//    var gameID = String()
//    var xUser = PFUser()
//    var oUser = PFUser()
//    var nameLabel = SKLabelNode()
//    var gameFinished = Bool()
//    var xObjId = String()
//    var oObjId = String()
//    var moveMade = Bool()
//    var recentMove = [[String:Int]]()
//    var xLinesParse : [[[String:Int]]] = []
//    var oLinesParse : [[[String:Int]]] = []
//    var layersToDelete = [LineShapeLayer]()
//    var activityIndicator = DGActivityIndicatorView()
//    var firstLoad = Bool()
//    var noReload = Bool()
//    let dimView = UIView()
//    
//    override func startGame() {
//        firstLoad = true
//        xTurn = xTurnLoad
//        super.startGame()
//        undoButton.removeFromSuperview()
//        restartButton.removeFromSuperview()
//        
//        let name = xUser["name"] as! String
//        nameLabel = SKLabelNode(text: name)
//        nameLabel.position = CGPoint(x: self.frame.width/2, y: turnLabel.position.y - 30)
//        nameLabel.fontColor = textColor
//        nameLabel.fontName = lightFontName
//        nameLabel.fontSize = 24
//        nameLabel.zPosition = 3
//        
//        self.addChild(nameLabel)
//        if !xTurn{
//            turnLabel.text = "O"
//            turnLabel.fontColor = oColor
//            nameLabel.text = oUser["name"] as? String
//        }
//        turnLabel.run(nodeAction)
//        setupBoard()
//        
//    }
//    
//    func setupBoard(){
//        if xLinesParse.count > 0 || oLinesParse.count > 0{
//            unLoadLoadedLines()
//        }
//        if xLines.count > 0 || xLines.count > 0{
//            drawLines()
//        }
//        if xLines.count == 0 && userTeam.rawValue == o{
//            let receiver = self.receiver()
//            PushNotificationController().pushNotificationNewGame(receiver, gameID: self.gameID)
//        }
//        if gameFinished{
//            finishedGameMessage()
//        }
//        
//        
//    }
//    
//    override func isXTurn() {
//        return
//    }
//    
//    override func animateNodes() {
//        var type = "X"
//        if !xTurn{
//            type = "O"
//        }
//        startActionForNodeType(type)
//        self.isUserInteractionEnabled = true
//    }
//    
//    func drawLines(){
//        
//        loopThroughLines("X")
//        loopThroughLines("O")
//        markIntersections("X")
//        markIntersections("O")
//        if recentMove.count > 0 && firstLoad{
//            noReload = true
//            lastMoveLoadAndAnimate()
//            firstLoad = false
//        }
//        
//    }
//    
//    func loopThroughLines(_ type: String){
//        var linesArray = xLines
//        if type == "O" {linesArray = oLines}
//        for line in linesArray{
//            if firstLoad{
//                line.lineWidth = 0
//                view?.layer.addSublayer(line)
//                animateWidthDelayed(line)
//            }else{
//                view?.layer.addSublayer(line)
//            }
//        }
//    }
//    
//    func lastMoveLoadAndAnimate(){
//        let pointsDict = recentMove[0]
//        var (pointA, pointB) = pointsFromDictionary(pointsDict)
//        pointA = self.convertPoint(toView: pointA)
//        pointB = self.convertPoint(toView: pointB)
//        let newPath = UIBezierPath()
//        newPath.move(to: pointA)
//        newPath.addLine(to: pointB)
//        var stroke = xColor.cgColor
//        if xTurn{
//            stroke = oColor.cgColor
//        }
//        let shape = LineShapeLayer(columnA: 0, rowA: 0, columnB: 0, rowB: 0, team: "N", path: newPath.cgPath, color: stroke)
//        shape.lineWidth = 0
//        view?.layer.addSublayer(shape)
//        layersToDelete.append(shape)
//        animationOnLastMove(shape)
//        
//    }
//    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard !gameFinished else {return}
//        super.touchesBegan(touches, with: event)
//    }
//    
//    override func isCurrentUserTurn() -> Bool {
//        if xTurn && xUser.username == PFUser.current()?.username{
//            return true
//        }else if !xTurn && oUser.username == PFUser.current()?.username{
//            return true
//        }else{
//            return false
//        }
//    }
//    
//    override func switchTurns() {
//        if xTurn{
//            xTurn = false
//            turnLabel.text = "O"
//            turnLabel.fontColor = oColor
//            nameLabel.text = oUser["name"] as? String
//            stopActionsOnGameLayer("X")
//            startActionForNodeType("O")
//        }else{
//            xTurn = true
//            turnLabel.text = "X"
//            turnLabel.fontColor = xColor
//            nameLabel.text = xUser["name"] as? String
//            stopActionsOnGameLayer("O")
//            startActionForNodeType("X")
//        }
//        guard moveMade else {return}
//        saveGame()
//    }
//    
//    fileprivate func prepareOldLinesForSave() -> [[[String:Int]]]{
//        var oldLineDicts = [[[String:Int]]]()
//        for line in previousMoveDetails.oldLines{
//            line.convertLinesForParse()
//            oldLineDicts.append(line.linesForParse)
//        }
//        return oldLineDicts
//    }
//    
//    fileprivate func prepareRecentMoveForSave(){
//        let coordinateDict = recentCoordinateToDict(recentCoordinates!)
//        recentMove.removeAll()
//        recentMove.append(coordinateDict)
//    }
//    
//    fileprivate func saveGame(){
//        dimView.frame = (view?.frame)!
//        dimBackground(dimView)
//        backButton.isUserInteractionEnabled = false
//        backButton.alpha = 0.5
//        
//        let oldLineDicts = prepareOldLinesForSave()
//        previousMoveDetails.newAppendedLine.convertLinesForParse()
//        prepareRecentMoveForSave()
//        XGameController.Singleton.sharedInstance.updateGameOnParse(xTurn, newLine: previousMoveDetails.newAppendedLine.linesForParse, oldLines: oldLineDicts, gameId: gameID, xId: xObjId, oId: oObjId, lastMove: recentMove) { (success) -> Void in
//            if success{
//                print("game saved")
//                let receiver = self.receiver()
//                if self.oLines.count > 0{
//                    if self.gameFinished{
//                        self.backButton.userInteractionEnabled = true
//                        self.backButton.alpha = 1
//                        self.gameSavedMessage(self.dimView)
//                        return
//                    }else{
//                        PushNotificationController().pushNotificationTheirTurn(receiver, gameID: self.gameID)
//                    }
//                }else{
//                    PushNotificationController().pushNotificationNewGame(receiver, gameID: self.gameID)
//                }
//                dispatch_async(dispatch_get_main_queue(),{
//                    self.gameSavedMessage(self.dimView)
//                    self.moveMade = false
//                    if !NSUserDefaults.standardUserDefaults().boolForKey("adsRemoved"){
//                        Chartboost.showInterstitial(CBLocationGameScreen)
//                    }
//                
//                })
//            }else{
//                self.backButton.userInteractionEnabled = true
//                self.backButton.alpha = 1
//                self.showFailToSaveAlert()
//                self.unDimBackground(self.dimView)
//            }
//        }
//    }
//    
//    fileprivate func gameSavedMessage(_ dimView: UIView){
//        let alert = SKLabelNode(text: "Move Sent")
//        alert.position = CGPoint(x: turnLabel.position.x, y: turnLabel.position.y + 50)
//        alert.fontColor = thirdColor
//        alert.fontName = boldFontName
//        alert.fontSize = 50
//        alert.zPosition = 3
//        addChild(alert)
//        alert.setScale(0.1)
//        alert.run(SKAction.scale(to: 1.0, duration: 1), completion: { () -> Void in
//            alert.run(SKAction.scale(to: 0.0, duration: 1))
//            self.backButton.isUserInteractionEnabled = true
//            self.backButton.alpha = 1
//            self.unDimBackground(dimView)
//        }) 
//    }
//    
//    func dimBackground(_ dimView: UIView){
//        activityIndicator = DGActivityIndicatorView(type: DGActivityIndicatorAnimationType .ballZigZagDeflect, tintColor: textColor, size: 200)
//        activityIndicator.frame = CGRect(x: (view?.frame.size.width)!/2 - 25, y: (view?.frame.size.height)!/2, width: 50.0, height: 50.0);
//        dimView.addSubview(activityIndicator)
//        activityIndicator.startAnimating()
//        dimView.backgroundColor = UIColor.darkGray
//        dimView.alpha = 0
//        DispatchQueue.main.async(execute: {
//            self.view?.addSubview(dimView)
//        })
//        
//        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
//            dimView.alpha = 0.6
//            }) { (done) -> Void in
//        }
//    }
//    
//    func unDimBackground(_ dimView: UIView){
//        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
//            dimView.alpha = 0.0
//            self.activityIndicator.alpha = 0.0
//            }) { (done) -> Void in
//                dimView.removeFromSuperview()
//        }
//    }
//    
//    fileprivate func showFailToSaveAlert(){
//        let alertController = UIAlertController(title: "Move Not Sent", message: "Check your network connection and try again", preferredStyle: .alert)
//        let cancelAction = UIAlertAction(title: "Okay", style: .cancel) { (action) in
//            self.undoLastMove()
//        }
//        alertController.addAction(cancelAction)
//        self.view?.window?.rootViewController?.present(alertController, animated: true, completion: nil)
//    }
//    
//    func convertLinesToDictionaries() -> ([[[String: Int]]],[[[String: Int]]] ){
//        var xlineDicts = [[[String: Int]]]()
//        var olineDicts = [[[String: Int]]]()
//        for line in xLines{
//            line.convertLinesForParse()
//            xlineDicts.append(line.linesForParse)
//        }
//        for line in oLines{
//            line.convertLinesForParse()
//            olineDicts.append(line.linesForParse)
//        }
//        return (xlineDicts, olineDicts)
//    }
//    
//    fileprivate func receiver() -> String{
//        var receiver = self.oUser.username
//        if self.xTurn{
//            receiver = self.xUser.username
//        }
//        return receiver!
//    }
//    
//    override func drawLineBetweenPoints(_ pointA: CGPoint, pointB: CGPoint, type: String) {
//        super.drawLineBetweenPoints(pointA, pointB: pointB, type: type)
//        moveMade = true
//    }
//    
//    override func declareWinner(_ winningTeam: String) {
//        gameFinished = true
//        super.declareWinner(winningTeam)
//    }
//    
//    override func gameover() {
//        XGameController.Singleton.sharedInstance.endGame(gameID)
//        let receiver = self.receiver()
//        PushNotificationController().pushNotificationGameFinished(receiver, gameID: self.gameID)
//        gameFinished = true
//        unDimBackground(self.dimView)
//        Chartboost.showInterstitial(CBLocationGameOver)
//    }
//    
//    func finishedGameMessage(){
//        let alertController = UIAlertController(title: "Game Finished", message: "This game is over. Start a new game with your friends!", preferredStyle: .alert)
//        let cancelAction = UIAlertAction(title: "Okay", style: .cancel) { (action) in}
//        alertController.addAction(cancelAction)
//        let replayAction = UIAlertAction(title: "Play Again", style: .default) { (action) -> Void in
//            if self.xUser.username == PFUser.current()?.username{
//                self.transitionToSetupScene(self.oUser)
//            }else{
//                self.transitionToSetupScene(self.xUser)
//            }
//
//        }
//        alertController.addAction(replayAction)
//        self.view?.window?.rootViewController?.present(alertController, animated: true, completion: nil)
//    }
//    
//    override dynamic func receivedGameNotification(_ notification: Notification) {
//        if let theGame = notification.userInfo!["game"] as? PFObject{
//            if theGame.objectId == gameID{
//                BoardSetupController().setupGame(theGame, size: self.size, completion: { (success, secondScene: MultiplayerBoard) -> Void in
//                    if success{
//                        DispatchQueue.main.async(execute: {
////                            self.transitiontoLoadedBoard(secondScene)
//                            self.firstLoad = false
//                            self.loadMove(secondScene)
//                            PFInstallation.current().badge = 0
//                        })
//                    }
//                })
//            }else{
//                super.receivedGameNotification(notification)
//            }
//        }
//    }
//    
//    func loadMove(_ loadedScene: MultiplayerBoard){
//        xLinesParse = loadedScene.xLinesParse
//        oLinesParse = loadedScene.oLinesParse
//        recentMove = loadedScene.recentMove
//        xTurn = loadedScene.xTurnLoad
//        updateTurnLabel()
//        if recentMove.count > 0{
//            let pointsDict = recentMove[0]
//            createPathFromDictionary(pointsDict)
//        }
//        gameFinished = loadedScene.gameFinished
//        if gameFinished{
//            finishedGameMessage()
//        }
//    }
//    
//    func finishLoadingMoves(){
//        if layersToDelete.count > 0{
//            finishAnimationOnLastMove(layersToDelete.last!)
//        }
//        removeLines()
//        unLoadLoadedLines()
//        drawLines()
//    }
//    
//    override func removeLines() {
//        super.removeLines()
//        xLines.removeAll()
//        oLines.removeAll()
//    }
//    
//    func updateTurnLabel(){
//        if !xTurn{
//            turnLabel.text = "O"
//            nameLabel.text = oUser["name"] as? String
//            turnLabel.fontColor = oColor
//            stopActionsOnGameLayer("X")
//            startActionForNodeType("O")
//        }else{
//            turnLabel.text = "X"
//            nameLabel.text = xUser["name"] as? String
//            turnLabel.fontColor = xColor
//            stopActionsOnGameLayer("O")
//            startActionForNodeType("X")
//        }
//    }
//    
//    override func removeViews() {
//        super.removeViews()
//        stopActionsOnGameLayer(turnString())
//        turnLabel.removeFromParent()
//        nameLabel.removeFromParent()
//        backButton.removeFromSuperview()
//        for layer in layersToDelete{
//            layer.removeFromSuperlayer()
//        }
//    }
//    
//    func submitPressed(){
//        print("submit pressed")
//        guard moveMade else {return}
//        saveGame()
//    }
//    
//    override func undoLastMove() {
//        moveMade = false
//        super.undoLastMove()
//    }
//    
//    //MARK: -LOADING THE BOARD
//    func unLoadLoadedLines(){
//        loopThroughParseLines("X")
//        loopThroughParseLines("O")
//    }
//    
//    func loopThroughParseLines(_ type: String){
//        var parseLines = xLinesParse
//        var stroke = xColor.cgColor
//        if type == "O" {parseLines = oLinesParse; stroke = oColor.cgColor}
//        for lineArray in parseLines{
//            var firstShapeNode = LineShapeLayer(columnA: 0, rowA: 0, columnB: 0, rowB: 0, team: "N")
//            for line in lineArray{
//                var (pointA, pointB) = pointsFromDictionary(line)
//                pointA = self.convertPoint(toView: pointA)
//                pointB = self.convertPoint(toView: pointB)
//                let path = firstShapeNode.createPath(pointA: pointA, pointB: pointB)
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
//    fileprivate func pointsFromDictionary(_ line: [String:Int]) -> (CGPoint, CGPoint){
//        let pointA = pointForColumn(line[columnAKey]!, row: line[rowAKey]!)
//        let pointB = pointForColumn(line[columnBKey]!, row: line[rowBKey]!)
//        return (pointA, pointB)
//    }
//    
//    func markIntersections(_ type: String){
//        var lineArray = xLines
//        if type == "O"{
//            lineArray = oLines
//        }
//        for line in lineArray{
//            for coordinate in line.coordinates{
//                let interCol = (coordinate.columnA + coordinate.columnB) / 2
//                let interRow = (coordinate.rowA + coordinate.rowB) / 2
//                let intersection = gridItem(column: interCol, row: interRow)
//                if intersection?.nodeType == NodeType.intersection && intersection?.nodePos.ptWho == ""{
//                    intersection?.nodePos.ptWho = type
//                }
//            }
//        }
//    }
//    
//    func recentCoordinateToDict(_ coordinate: RecentCoordinates) -> [String: Int]{
//        let dict = [columnAKey: coordinate.columnA,
//            rowAKey: coordinate.rowA,
//            columnBKey: coordinate.columnB,
//            rowBKey: coordinate.rowB]
//        return dict
//    }
//    
//    func createPathFromDictionary(_ line: [String:Int]){
//        var (pointA, pointB) = pointsFromDictionary(line)
//        pointA = self.convertPoint(toView: pointA)
//        pointB = self.convertPoint(toView: pointB)
//        let newPath = UIBezierPath()
//        newPath.move(to: pointA)
//        newPath.addLine(to: pointB)
//        var stroke = xColor.cgColor
//        if xTurn{
//            stroke = oColor.cgColor
//        }
//        let shape = LineShapeLayer(columnA: 0, rowA: 0, columnB: 0, rowB: 0, team: "N", path: newPath.cgPath, color: stroke)
//        shape.lineWidth = 0
//        view?.layer.addSublayer(shape)
//        animateInLastMove(shape)
//        layersToDelete.append(shape)
//        
//    }
//    
//    //MARK: - LINE ANIMATIONS
//    func animateInLastMove(_ shapeLayer: LineShapeLayer){
//        let animation1 = CABasicAnimation(keyPath: "lineWidth")
//        animation1.fromValue = 0
//        animation1.toValue = 4
//        animation1.beginTime = CACurrentMediaTime()
//        animation1.duration = 0.5
//        animation1.repeatCount = 0
//        animation1.delegate = self
//        animation1.fillMode = kCAFillModeForwards
//        animation1.isRemovedOnCompletion = false
//        shapeLayer.add(animation1, forKey: animation1.keyPath)
//    }
//    
//    func finishAnimationOnLastMove(_ shapeLayer: LineShapeLayer){
//        let animation2 = CABasicAnimation(keyPath: "lineWidth")
//        animation2.fromValue = 4
//        animation2.toValue = 7
//        animation2.duration = 0.5
//        animation2.autoreverses = true
//        animation2.repeatCount = 5
//        animation2.fillMode = kCAFillModeForwards
//        animation2.isRemovedOnCompletion = true
//        shapeLayer.add(animation2, forKey: animation2.keyPath)
//
//    }
//    func animationOnLastMove(_ shapeLayer: LineShapeLayer){
//        let animation2 = CABasicAnimation(keyPath: "lineWidth")
//        animation2.fromValue = 4
//        animation2.toValue = 10
//        animation2.duration = 0.5
//        animation2.autoreverses = true
//        animation2.beginTime = CACurrentMediaTime() + 2.5
//        animation2.repeatCount = 5
//        animation2.fillMode = kCAFillModeForwards // keep to value after finishing
//        animation2.isRemovedOnCompletion = true // don't remove after finishing
//        shapeLayer.add(animation2, forKey: animation2.keyPath)
//        
//    }
//
//    func animateWidthDelayed(_ line: LineShapeLayer){
//        let animation = CABasicAnimation(keyPath: "lineWidth")
//        animation.toValue = 4
//        animation.duration = 1.0
//        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut) // animation curve is Ease Out
//        animation.beginTime = CACurrentMediaTime() + 1.5
//        animation.fillMode = kCAFillModeBoth // keep to value after finishing
//        animation.isRemovedOnCompletion = false // don't remove after finishing
//        line.add(animation, forKey: animation.keyPath)
//    }
//
//    
//    override func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
//        if flag && !noReload{
//            finishLoadingMoves()
//        }
//        noReload = false
//    }
//
//    //MARK: - TRANSITIONS
//    override func transitionToMainScene() {
//        let mainScene = GameScene(size: self.size)
//        mainScene.scaleMode = .aspectFill
//        self.scene?.view?.presentScene(mainScene)
//    }
//    
//    func transitionToSetupScene(_ opponent: PFUser){
//        let nextScene = SingleSetupScene(size: self.size, type: SingleSetupScene.GameType.online)
//        nextScene.opponent = opponent
//        let transition = SKTransition.crossFade(withDuration: 0.75)
//        nextScene.scaleMode = .aspectFill
//        self.scene?.view?.presentScene(nextScene, transition: transition)
//        removeViews()
//    }
//}
//
//
//
