//
//  Board.swift
//  XsAndOs
//
//  Created by Derik Flanary on 11/5/15.
//  Copyright © 2015 Derik Flanary. All rights reserved.
//
import Parse 
import SpriteKit

//var dim = 9
let bottomPadding : CGFloat = 100

enum LastMove {
    case SingleLine
    case AppendedLine
}

struct PreviousMoveDetails {
    var oldLines = [LineShapeLayer]()
    var previousIntersection : LastIntersectionLocation
    var moveUnDid = false
    var newAppendedLine : LineShapeLayer
}

struct LastIntersectionLocation {
    var row : Int
    var col : Int
}

class Board: XandOScene {
    
    var rows : Int
    var dim : Int
    var nodeX = [Nodes]()
    var nodeO = [Nodes]()
    var yIsopin : CGFloat?    // distance between nodes Vertical
    var xIsopin : CGFloat?
    let gameLayer = SKNode()
    var grid : Array2D<Nodes>
    var selectedNode = SKSpriteNode()
    var secondSelectedNode = SKSpriteNode()
    var xTurn : Bool = true
    var xLines = [LineShapeLayer]()
    var oLines = [LineShapeLayer]()
    var movingTouches = Set<UITouch>()
    var touchedLocations = [CGPoint]()
    var turnLabel = SKLabelNode()
    var startPoint = CGPoint()
    var nextPoint = CGPoint()
    var pointsConnected = false
    var potentialShapeNode = CAShapeLayer()
    var restartButton = UIButton()
    var lastMove = LastMove.SingleLine
    let undoButton = UIButton()
    let backButton = UIButton()
    var nodeAction = SKAction()
    var lastIntersection = LastIntersectionLocation(row: 0, col: 0)
    var previousMoveDetails = PreviousMoveDetails(oldLines: [], previousIntersection: LastIntersectionLocation(row: 0, col: 0), moveUnDid: true, newAppendedLine: LineShapeLayer(columnA: 0, rowA: 0, columnB: 0, rowB: 0, team: "N"))
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(size: CGSize, theDim: Int, theRows: Int) {
        dim = theDim
        grid = Array2D(columns: dim, rows: dim)
        rows = theRows
        super.init(size: size)
        xIsopin = self.frame.size.width / CGFloat(dim)
        yIsopin = xIsopin
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        super.didMoveToView(view)
        startGame()
    }
    
    
//GAME SETUP
    func startGame(){
        self.backgroundColor = SKColor.whiteColor()
        gameLayer.position = CGPointMake(0, 0)
        addChild(gameLayer)
        setUpMainAnimation()
        buildArrayOfNodes()
        drawSquare()
        
        restartButton.frame = CGRectMake((self.view?.frame.size.width)!/2 - 50, 20, 100, 30)
        restartButton.setTitleColor(UIColor.darkTextColor(), forState: .Normal)
        restartButton.setTitleColor(UIColor.lightTextColor(), forState: .Highlighted)
        restartButton.setTitle("Restart", forState: UIControlState.Normal)
        restartButton.addTarget(self, action: "restartPressed", forControlEvents: .TouchUpInside)
        restartButton.tag = 10
        self.view?.addSubview(restartButton)
        
        backButton.frame = CGRectMake(10, 20, 50, 30)
        backButton.setTitle("Main", forState: .Normal)
        backButton.setTitleColor(UIColor(white: 0.4, alpha: 1), forState: .Normal)
        backButton.setTitleColor(UIColor(white: 0.7, alpha: 1), forState: .Highlighted)
        backButton.addTarget(self, action: "mainPressed", forControlEvents: .TouchUpInside)
        backButton.tag = 20
        self.view?.addSubview(backButton)
        
        undoButton.frame = CGRectMake((self.view?.frame.size.width)! - 60, 20, 50, 30)
        undoButton.setTitle("Undo", forState: .Normal)
        undoButton.setTitleColor(UIColor(white: 0.4, alpha: 1), forState: .Normal)
        undoButton.setTitleColor(UIColor(white: 0.7, alpha: 1), forState: .Highlighted)
        undoButton.addTarget(self, action: "undoLastMove", forControlEvents: .TouchUpInside)
        undoButton.tag = 30
        self.view?.addSubview(undoButton)
        undoButton.hidden = true
        
        turnLabel = SKLabelNode(text: "X")
        turnLabel.position = CGPointMake(self.frame.width/2, yIsopin! * CGFloat(dim) + 150)
        turnLabel.fontColor = SKColor.blackColor()
        turnLabel.zPosition = 3
        self.addChild(turnLabel)
        
        isXTurn()
    }
    
    func setUpMainAnimation(){
        let fadeOut = SKAction.scaleTo(1.15, duration: 0.5)
        let fadeIn = SKAction.scaleTo(1.0, duration: 0.5)
        let pulse = SKAction.sequence([fadeOut, fadeIn])
        let pulseForever = SKAction.repeatActionForever(pulse)
        nodeAction = pulseForever
    }
    
//DRAWING THE BOARD
    func buildArrayOfNodes(){
        var set = Set<Nodes>()
        
        for  theRow in 0...dim - 1{
            for column in 0...dim - 1 {
                let node = Nodes(column: column, row: theRow, theNodeType: NodeType.Empty)
                if (theRow + 1) % 2 == 0 && (column + 1) % 2 != 0{  //if row is even and column is odd
                    node.nodeType = NodeType.O
                    node.sprite = SKSpriteNode(imageNamed: "o")
                    node.sprite?.name = "O"
                }else if (theRow + 1) % 2 != 0 && (column + 1) % 2 == 0{
                    node.nodeType = NodeType.X
                    node.sprite = SKSpriteNode(imageNamed: "x")
                    node.sprite?.name = "X"
                }else{
                    if theRow == 0 || theRow == dim - 1 || column == 0 || column == dim - 1{
                        node.nodeType = NodeType.Empty
                    }else{
                        node.nodeType = NodeType.Intersection
                    }
                }
                grid[column, theRow] = node
                set.insert(node)
                
            }
        }
        
        paintXsnOs(set)
    }
    
    func paintXsnOs(nodes: Set<Nodes>){
        for node in nodes{

            if node.sprite != nil{
                let position = pointForColumn(node.nodePos.column!, row: node.nodePos.row!, size: (node.sprite?.frame.size.width)!)
                let sprite = node.sprite
                sprite?.color = SKColor.redColor()
                sprite?.position = position
                if dim > 11{
                    sprite?.size = CGSizeMake(xIsopin!/1.1, yIsopin!/1.1)
                }else{
                    sprite?.size = CGSizeMake(xIsopin!/1.3, yIsopin!/1.3)
                }
                sprite?.anchorPoint = CGPointMake(0.5, 0.5)
                sprite?.zPosition = 2
                gameLayer.addChild(sprite!)
            }
        }
        animateNodes()
    }
    
    func pointForColumn(column: Int, row: Int, size: CGFloat) -> CGPoint {
        return CGPoint(
            x: CGFloat(column) * xIsopin! + xIsopin!/2,
            y: CGFloat(row) * yIsopin! + bottomPadding)
    }
    
    func drawSquare(){
        
        let x = xIsopin! * (CGFloat(dim) - CGFloat(rows) + 0.5)
        let y = bottomPadding + (yIsopin! * (CGFloat(dim) - CGFloat(rows)))
        let width = (self.view?.frame.size.width)! - (xIsopin! * 2)
        let height = width
        let square = SKShapeNode(rectOfSize: CGSize(width: width, height: height))
        square.name = "square"
        square.fillColor = SKColor.clearColor()
        square.position = CGPointMake(x, y)
        square.zPosition = 0
        square.strokeColor = SKColor.lightGrayColor()
        self.addChild(square)

    }
    
    func animateNodes(){
        startActionForNodeType("X")
    }
    
    func startActionForNodeType(type: String){
        gameLayer.enumerateChildNodesWithName(type, usingBlock: {
            node, stop in
            node.runAction(self.nodeAction)
            // do something with node or stop
        })
    }
    
    func stopActionsOnGameLayer(type: String){
        gameLayer.enumerateChildNodesWithName(type, usingBlock: {
            node, stop in
            node.removeAllActions()
            node.runAction(SKAction.scaleTo(1.0, duration: 0.5))
            // do something with node or stop
        })
    }
    
    func isXTurn(){
        xTurn = true
    }
    
    func turnString() -> String{
        if xTurn{
            return "X"
        }else{
            return "O"
        }
    }
    
    func isCurrentUserTurn() ->Bool{
        return true
    }
    
//TOUCHING AND DRAWING FUNCTIONS
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        guard isCurrentUserTurn() else{return}
        for touch in touches {
            let location = touch.locationInNode(self.gameLayer)
            let touchedNode = self.nodeAtPoint(location)
            
            if touchedNode.name == "X" || touchedNode.name == "O"{
                
                if selectedNode.name == "X" && touchedNode.name == "X"{
                    guard xTurn else{return}
                    if isPotentialMatchingNode(selectedNode, secondSprite: touchedNode, type: "X"){
                        drawLineBetweenPoints(selectedNode.position, pointB: touchedNode.position, type: selectedNode.name!)
                        switchTurns()
                    }
                    resetSelectedNode()
                }else if selectedNode.name == "O" && touchedNode.name == "O"{
                    guard !xTurn else{return}
                    if isPotentialMatchingNode(selectedNode, secondSprite: touchedNode, type: "O"){
                        drawLineBetweenPoints(selectedNode.position, pointB: touchedNode.position, type: selectedNode.name!)
                        switchTurns()
                    }
                    resetSelectedNode()
                }else{
                    selectedNode.setScale(1.0)
                    selectedNode = touchedNode as! SKSpriteNode
                    if touchedNode.name == "X" && xTurn{
                        selectedNode.setScale(1.25)
                        startPoint = selectedNode.position
                    }else if touchedNode.name == "O" && !xTurn{
                        selectedNode.setScale(1.25)
                        startPoint = selectedNode.position
                    }
                }
            }else{
                resetSelectedNode()
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard isCurrentUserTurn() else{return}
        for touch: AnyObject in touches{
            touchedLocations.append(touch.locationInNode(self.gameLayer))
            let location = touch.locationInNode(self.gameLayer)
            let touchedNode = self.nodeAtPoint(location)
            
            if !pointsConnected && startPoint != CGPointZero{
                if touchedNode.name == "X" && xTurn && touchedNode != selectedNode{
                    if isPotentialMatchingNode(selectedNode, secondSprite: touchedNode, type: ""){
                        nextPoint = touchedNode.position
                        drawPotentialLineBetweenPoints(startPoint, pointB: nextPoint, type: "X")
                        pointsConnected = true
                        return
                    }else{
                        drawPotentialLineBetweenPoints(startPoint, pointB: location, type: "N")
                    }
                }else if touchedNode.name == "O" && !xTurn{
                    if isPotentialMatchingNode(selectedNode, secondSprite: touchedNode, type: ""){
                        nextPoint = touchedNode.position
                        drawPotentialLineBetweenPoints(startPoint, pointB: nextPoint, type: "O")
                        pointsConnected = true
                        return
                    }else{
                        drawPotentialLineBetweenPoints(startPoint, pointB: location, type: "N")
                    }
                }else{
                    nextPoint = location
                    drawPotentialLineBetweenPoints(startPoint, pointB: nextPoint, type: "")
                }
            }else{
                return
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard isCurrentUserTurn() else{return}
        potentialShapeNode.removeFromSuperlayer()
        pointsConnected = false
        startPoint = CGPointZero
        for theTouch: AnyObject in touches{
            touchedLocations.append(theTouch.locationInNode(self.gameLayer))
        }
        for location: CGPoint in touchedLocations {
            let touchedNode = self.nodeAtPoint(location)
            if selectedNode.name == "X" && touchedNode.name == "X"{
                guard xTurn else{touchedLocations.removeAll(); return}
                if isPotentialMatchingNode(selectedNode, secondSprite: touchedNode, type: "X"){
                    drawLineBetweenPoints(selectedNode.position, pointB: touchedNode.position, type: selectedNode.name!)
                    cleanUpMove()
                    return
                }
            }else if selectedNode.name == "O" && touchedNode.name == "O"{
                guard !xTurn else{touchedLocations.removeAll(); return}
                if isPotentialMatchingNode(selectedNode, secondSprite: touchedNode, type: "O"){
                    drawLineBetweenPoints(selectedNode.position, pointB: touchedNode.position, type: selectedNode.name!)
                    cleanUpMove()
                    return
                }
            }else{
                touchedLocations.removeAll()
            }
        }
        resetSelectedNode()
        touchedLocations.removeAll()
    }
    
    private func cleanUpMove(){
        switchTurns()
        resetSelectedNode()
        touchedLocations.removeAll()
    }
    
    private func resetSelectedNode(){
        selectedNode.setScale(1.0)
        selectedNode = SKSpriteNode()
    }
    
    func switchTurns(){

        if turnLabel.text == "X"{
            xTurn = false
            turnLabel.text = "O"
            stopActionsOnGameLayer("X")
            startActionForNodeType("O")
        }else{
            xTurn = true
            turnLabel.text = "X"
            stopActionsOnGameLayer("O")
            startActionForNodeType("X")
        }
    }
    
    func isPotentialMatchingNode(firstSprite: SKSpriteNode, secondSprite: SKNode, type: String) -> Bool{
        let (column, row, column2, row2) = convertSpritesToPoints(firstSprite, secondSprite: secondSprite)
        if column == column2 || column - column2 == -2 || column - column2 == 2{
            if row == row2 && column != column2 || row - row2 == -2 || row - row2 == 2 {
                var interRow = 0
                var interCol = 0
                if column == column2 || row == row2{
                    if column == column2{
                        interCol = Int(column)
                        if column == 0 || column2 == Float(dim) - 1{
                            return false
                        }else if row > row2{
                            interRow = Int(row2) + 1
                        }else{
                            interRow = Int(row) + 1
                        }
                    }else{
                        interRow = Int(row)
                        if row == 0 || row2 == Float(dim) - 1{
                            return false
                        }else if column > column2{
                            interCol = Int(column2) + 1
                        }else{
                            interCol = Int(column) + 1
                        }
                    }
                    let intersection = gridItemAtColumn(interCol, row: interRow)
                    if intersection?.nodeType == NodeType.Intersection && intersection?.nodePos.ptWho == ""{
                        intersection?.nodePos.ptWho = type
                        lastIntersection = LastIntersectionLocation(row: interRow, col: interCol)
                        previousMoveDetails.previousIntersection = lastIntersection
                        previousMoveDetails.oldLines.removeAll()
                        previousMoveDetails.moveUnDid = false
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func convertSpritesToPoints(firstSprite: SKSpriteNode, secondSprite: SKNode) -> (column: Float, row: Float, column2: Float, row2: Float){
        var (success, column, row) = convertPoint(firstSprite.position)
        if success {
            column = round(column)
            row = round(row)
        }
        var (success2, column2, row2) = convertPoint(secondSprite.position)
        if success2{
            column2 = round(column2)
            row2 = round(row2)
        }
        return(column, row, column2, row2)
    }
    
    func drawPotentialLineBetweenPoints(var pointA: CGPoint, var pointB: CGPoint, type: String){
        potentialShapeNode.removeFromSuperlayer()
        pointA = convertPointToView(pointA)
        pointB = convertPointToView(pointB)
        let newPath = UIBezierPath()
        newPath.moveToPoint(pointA)
        newPath.addLineToPoint(pointB)
//        let path = createLineAtPoints(pointA, pointB: pointB)
        potentialShapeNode.path = newPath.CGPath
//        potentialShapeNode = SKShapeNode(path: path)
        potentialShapeNode.strokeColor = UIColor(white: 0.4, alpha: 0.6).CGColor
        potentialShapeNode.lineWidth = 3
        view?.layer.addSublayer(potentialShapeNode)
//        addChild(potentialShapeNode)
    }
    
    func drawLineBetweenPoints(var pointA: CGPoint,var pointB: CGPoint, type: String){
        let (columnA, rowA, columnB, rowB) = calculateColumnsAndRows(pointA, pointB: pointB)
        var match = false
        var matchedLine = LineShapeLayer(columnA: 0, rowA: 0, columnB: 0, rowB: 0, team: "N")
        pointA = convertPointToView(pointA)
        pointB = convertPointToView(pointB)
        let path = matchedLine.createPath(pointA: pointA, pointB: pointB)
        
        var lineArray = xLines
        var strokeColor = UIColor.redColor().CGColor
        if type == "O"{
            lineArray = oLines
            strokeColor = UIColor.blueColor().CGColor
        }
        var lineToDelete = LineShapeLayer(columnA: 0, rowA: 0, columnB: 0, rowB: 0, team: "N")
        //check every coordinate in xlines to see if any existing lines touch the new line then add new line
        for lineShapeLayer in lineArray{
            (match, matchedLine, lineToDelete) = loopThroughCoordinates(lineShapeLayer, matchedLine: matchedLine, path: path, columnA: columnA, rowA: rowA, columnB: columnB, rowB: rowB, match: match)
        }
        
        deleteLineFromArrays(lineToDelete)
        //If new line doesn't touch an existing line, make a new line
        if !match{
            let shapeNode = LineShapeLayer(columnA: columnA, rowA: rowA, columnB: columnB, rowB: rowB, team: type, path: path, color: strokeColor)
            shapeNode.strokeEnd = 0.0
            view?.layer.addSublayer(shapeNode)
            animatePath(shapeNode)
            appendLineArrays(shapeNode)
            lastMove = .SingleLine
        }
        undoButton.hidden = false
    }
    
    func loopThroughCoordinates(lineShapeLayer: LineShapeLayer, var matchedLine: LineShapeLayer, path: CGPathRef, columnA: Int, rowA: Int, columnB: Int, rowB: Int, var match: Bool) -> (match:Bool, matchedLine: LineShapeLayer, lineDelete: LineShapeLayer){
        var lineToDelete = LineShapeLayer(columnA: 0, rowA: 0, columnB: 0, rowB: 0, team: "N")
        
        for coordinate in lineShapeLayer.coordinates{
            if coordinate.columnA == columnA && coordinate.rowA == rowA || coordinate.columnA == columnB && coordinate.rowA == rowB || coordinate.columnB == columnA && coordinate.rowB == rowA || coordinate.columnB == columnB && coordinate.rowB == rowB {
                if match{
                    //If the new line connects two existing lines, add the second path to the first one
                    matchedLine.appendPath(lineShapeLayer.path!)
                    matchedLine.addCoordinatesFromLine(lineShapeLayer)
                    lineToDelete = lineShapeLayer
                    previousMoveDetails.oldLines.append(lineShapeLayer)
                    previousMoveDetails.newAppendedLine = matchedLine
                    checkForWinner(matchedLine)
                    break
                }else{
                    //If the first coordinate matches, add the path to the line and then if will keep looking if the other coordinate on the path matches another line and if so it will add this line to that line.
                    match = true
                    createLineCopy(lineShapeLayer)
                    lastMove = .AppendedLine
                    matchedLine = lineShapeLayer
//                    animateLineWithPath(path, line: matchedLine)
                    matchedLine.appendPath(path)
                    matchedLine.addCoordinate(columnA, rowA: rowA, columnB: columnB, rowB: rowB)
                    previousMoveDetails.newAppendedLine = matchedLine
                    checkForWinner(lineShapeLayer)
                    break
                }
            }
        }
        return (match, matchedLine, lineToDelete)
    }
    
    func appendLineArrays(shapeNode : LineShapeLayer){
        if shapeNode.team == "X"{
            xLines.append(shapeNode)
        }else{
            oLines.append(shapeNode)
        }
    }
    
    func deleteLineFromArrays(lineToDelete: LineShapeLayer){
        if lineToDelete.team == "X"{
            if let index = xLines.indexOf(lineToDelete){
                xLines.removeAtIndex(index)
            }
        }else if lineToDelete.team == "O"{
            if let index = oLines.indexOf(lineToDelete){
                oLines.removeAtIndex(index)
            }
        }
    }
    
    func createLineAtPoints(pointA: CGPoint, pointB: CGPoint) -> CGPathRef{
        let ref = CGPathCreateMutable()
        CGPathMoveToPoint(ref, nil, pointA.x, pointA.y)
        CGPathAddLineToPoint(ref, nil, pointB.x, pointB.y)
        return ref
    }
    
    func createLineCopy(lineShapeLayer: LineShapeLayer) -> LineShapeLayer{
        let line = LineShapeLayer(columnA: 0, rowA: 0, columnB: 0, rowB: 0, team: "N")
        line.copyLineValues(lineShapeLayer)
        previousMoveDetails.oldLines.append(line)
        return line
    }
    
    func animatePath(line: LineShapeLayer){
        let pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.duration = 0.25
        pathAnimation.fromValue = 0.0
        pathAnimation.toValue = 1.0
        pathAnimation.fillMode = kCAFillModeBoth // keep to value after finishing
        pathAnimation.removedOnCompletion = false
        line.addAnimation(pathAnimation, forKey: "strokeEndAnimation")
    }
    
    func animateLineWithPath(path: CGPathRef, line: LineShapeLayer){
        let pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.duration = 0.25
        let bez = UIBezierPath(CGPath: path)
        pathAnimation.fromValue = UIBezierPath(CGPath: line.path!)
        pathAnimation.toValue = bez
        pathAnimation.fillMode = kCAFillModeBoth // keep to value after finishing
        pathAnimation.removedOnCompletion = false
        line.addAnimation(pathAnimation, forKey: "strokeEndAnimation")
    }
    
    
    
    
//WINNING FUNCTIONS
    func checkForWinner(line: LineShapeLayer){
        //check each coordinate on the newly appended line to see if it touches both ends of the board
        if line.team == "X"{
            loopCoordinatesForXWinner(line)
        }else if line.team == "O"{
            loopCoordinatesForOWinner(line)
        }
    }
    
    func loopCoordinatesForXWinner(line: LineShapeLayer){
        var edgeOne = false
        var edgeTwo = false
        for coordinate in line.coordinates{
            if coordinate.rowA == dim - 1 || coordinate.rowB == dim - 1{
                edgeOne = true
            }
            if coordinate.rowA == 0 || coordinate.rowB == 0{
                edgeTwo = true
            }
            if edgeOne && edgeTwo{
                declareWinner(line.team!)
                break
            }
        }
    }
    
    func loopCoordinatesForOWinner(line: LineShapeLayer){
        var edgeOne = false
        var edgeTwo = false
        for coordinate in line.coordinates{
            if coordinate.columnA == dim - 1 || coordinate.columnB == dim - 1{
                edgeOne = true
            }
            if coordinate.columnA == 0 || coordinate.columnB == 0{
                edgeTwo = true
            }
            if edgeOne && edgeTwo{
                declareWinner(line.team!)
                break
            }
        }
    }
    
    func declareWinner(winningTeam: String){
        let alertController = UIAlertController(title: "\(winningTeam) Wins", message: "Play again?", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Okay", style: .Cancel) { (action) in
            self.gameover()
        }
        alertController.addAction(cancelAction)
        self.view?.window?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
    }
    
//UNDO MOVE//
    func undoLastMove(){
        undoButton.hidden = true
        switch lastMove{
        case .SingleLine:
            undoSingleLine()
            break
        case .AppendedLine:
            undoAppendedLine()
            break
        }
    }
    
    func undoSingleLine(){
        var lineArray = lineArrayForLastMove()
        guard lineArray.count > 0 else{return}
        let lastLine = lineArray.last
        lastLine?.removeFromSuperlayer()
        lineArray.removeLast()
        removeLastLineFromArray()
        resetIntersection()
        switchTurns()
    }
    
    private func removeLastLineFromArray(){
        if xTurn{
            oLines.removeLast()
        }else{
            xLines.removeLast()
        }
    }
    
    private func resetIntersection(){
        let intersection = gridItemAtColumn(lastIntersection.col, row: lastIntersection.row)
        intersection?.nodePos.ptWho = ""
    }
    
    func undoAppendedLine(){
        guard !previousMoveDetails.moveUnDid else{return}
        var lineArray = lineArrayForLastMove()
        let index = lineArray.indexOf(previousMoveDetails.newAppendedLine)
        let lineToRemove = lineArray[index!]
        lineToRemove.removeFromSuperlayer()
        lineArray.removeAtIndex(index!)
        let lineToAdd = previousMoveDetails.oldLines[0]
        lineArray.append(lineToAdd)
        view?.layer.addSublayer(lineToAdd)
        if xTurn{
            oLines = lineArray
        }else{
            xLines = lineArray
        }
        resetIntersection()
        previousMoveDetails.moveUnDid = true
        switchTurns()
    }
    
    private func lineArrayForLastMove() -> [LineShapeLayer]{
        if xTurn{
            return oLines
        }else{
            return xLines
        }
    }

//RESETTING GAME
    
    func gameover(){
        resetBoard()
    }
    
    func resetBoard(){
        //delete all objects on the board
        removeViews()
        tranistionToNewBoard()
    }
    
    func tranistionToNewBoard(){
        let secondScene = Board(size: self.size, theDim: dim, theRows: rows)
        let transition = SKTransition.crossFadeWithDuration(0.75)
        secondScene.scaleMode = SKSceneScaleMode.AspectFill
        self.scene!.view?.presentScene(secondScene, transition: transition)
    }
    
//SUPPORT FUNCTIONS
    
    //Takes a point and returns the column and row for that point
    func calculateColumnsAndRows(pointA: CGPoint, pointB: CGPoint) -> (columnA: Int, rowA: Int, columnB: Int, rowB: Int){
        var columnA : Int = 0
        var rowA : Int = 0
        var columnB : Int = 0
        var rowB : Int = 0
        //return a row and column for the two selected points
        var (successA, cA, rA) = convertPoint(pointA)
        if successA {
            cA = round(cA)
            rA = round(rA)
            columnA = Int(cA)
            rowA = Int(rA)
        }
        var (successB, cB, rB) = convertPoint(pointB)
        if successB {
            cB = round(cB)
            rB = round(rB)
            columnB = Int(cB)
            rowB = Int(rB)
        }
        return (columnA, rowA, columnB, rowB)
    }
    
    func convertPoint(point: CGPoint) -> (success: Bool, column: Float, row: Float) {
        if point.x >= 0 && point.x < CGFloat(dim) * xIsopin! &&
            point.y >= 0 && point.y < CGFloat(dim) * yIsopin! + bottomPadding {
                return (true, Float((point.x - (xIsopin!/2)) / xIsopin!), Float((point.y - bottomPadding) / yIsopin!))
        } else {
            return (false, 0, 0)  // invalid location
        }
    }
    
    func gridItemAtColumn(column: Int, row: Int) -> Nodes? {
        assert(column >= 0 && column <= dim)
        assert(row >= 0 && row <= dim)
        return grid[column, row]
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    override func removeViews(){
        self.removeAllChildren()
        self.removeAllActions()
        for shape in xLines{
            shape.removeFromSuperlayer()
        }
        for shape in oLines{
            shape.removeFromSuperlayer()
        }
        nodeX.removeAll()
        nodeO.removeAll()
        xLines.removeAll()
        oLines.removeAll()
        grid.removeArray()
        restartButton.removeFromSuperview()
        backButton.removeFromSuperview()
        undoButton.removeFromSuperview()
    }
    
//BUTTON FUNCTIONS
    
    func restartPressed(){
        resetBoard()
    }
    
    func mainPressed(){
        removeViews()
        transitionToMainScene()
    }
    
    func transitionToMainScene(){
        let mainScene = GameScene(size: self.size)
        let transition = SKTransition.fadeWithDuration(2.0)
        mainScene.scaleMode = .AspectFill
        self.scene?.view?.presentScene(mainScene, transition: transition)
    }
}
