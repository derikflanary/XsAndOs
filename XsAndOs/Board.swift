//
//  Board.swift
//  XsAndOs
//
//  Created by Derik Flanary on 11/5/15.
//  Copyright © 2015 Derik Flanary. All rights reserved.
//
import Parse 
import SpriteKit

let bottomPadding : CGFloat = 100
let x = "X"
let o = "O"

class Board: XandOScene {
    //MARK: - PROPERTIES
    enum LastMove {
        case singleLine
        case appendedLine
    }
    
    enum UserTeam: String {
        case X = "X"
        case O = "O"
    }
    
    var rows : Int
    var dim : Int
    var nodeX = [Node]()
    var nodeO = [Node]()
    var yIsopin : CGFloat?    // distance between nodes Vertical
    var xIsopin : CGFloat?
    let gameLayer = SKNode()
    var grid : Array2D<Node>
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
    var restartButton = Button()
    var lastMove = LastMove.singleLine
    let undoButton = Button()
    let backButton = Button()
    var nodeAction = SKAction()
    var square = CAShapeLayer()
    var winner = false
    var userTeam = UserTeam.X
    var aiGame : Bool
    var difficulty : Difficulty
    var recentCoordinates : RecentCoordinates?
    var lastIntersection = LastIntersectionLocation(row: 0, col: 0)
    var previousMoveDetails = PreviousMoveDetails(oldLines: [], previousIntersection: LastIntersectionLocation(row: 0, col: 0), moveUnDid: true, newAppendedLine: LineShapeLayer(columnA: 0, rowA: 0, columnB: 0, rowB: 0, team: "N"))
    let cheerSound = SoundEffect(fileName: "cheer")
    let squareSound = SoundEffect(fileName: "square")
    let boardSound = SoundEffect(fileName: "board")
    let loseSound = SoundEffect(fileName: "lose")
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: INIT
    init(size: CGSize, theDim: Int, theRows: Int, userTeam: UserTeam, aiGame: Bool) {
        dim = theDim
        grid = Array2D(columns: dim, rows: dim)
        rows = theRows
        self.aiGame = aiGame
        self.difficulty = .easy
        super.init(size: size)
        xIsopin = self.frame.size.width / CGFloat(dim)
        yIsopin = xIsopin
        self.userTeam = userTeam
        
    }
    
    init(size: CGSize, theDim: Int, theRows: Int, userTeam: UserTeam, aiGame: Bool, difficulty: Difficulty) {
        dim = theDim
        grid = Array2D(columns: dim, rows: dim)
        rows = theRows
        self.aiGame = aiGame
        self.difficulty = difficulty
        super.init(size: size)
        xIsopin = self.frame.size.width / CGFloat(dim)
        yIsopin = xIsopin
        self.userTeam = userTeam
        
    }
    
    
    // MARK: - GAME SETUP
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        super.didMove(to: view)
        self.view?.viewWithTag(1000)?.removeFromSuperview()
        startGame()
    }
    
    func startGame(){
        gameLayer.position = CGPoint(x: 0, y: 0)
        self.isUserInteractionEnabled = false
        addChild(gameLayer)
        setUpMainAnimation()
        buildArrayOfNodes()
        drawSquare()
        
        restartButton.frame = CGRect(x: (self.view?.frame.size.width)!/2 - 50, y: 20, width: 100, height: 50)
        restartButton.setTitleColor(UIColor.white, for: UIControl.State())
        restartButton.setTitleColor(UIColor.lightText, for: .highlighted)
        restartButton.setTitle("Restart", for: UIControl.State())
        restartButton.backgroundColor = thirdColor
        restartButton.addTarget(self, action: #selector(Board.restartPressed), for: .touchUpInside)
        restartButton.tag = 10
        self.view?.addSubview(restartButton)
        restartButton.titleLabel?.font = UIFont(name: boldFontName, size: 18)
        
        backButton.frame = CGRect(x: 10, y: 20, width: 50, height: 50)
        backButton.backgroundColor = xColor
        backButton.setImage(UIImage(named: "home"), for: UIControl.State())
        backButton.imageView?.contentMode = .center
        backButton.addTarget(self, action: #selector(Board.mainPressed), for: .touchUpInside)
        backButton.tag = 20
        self.view?.addSubview(backButton)
        
        undoButton.frame = CGRect(x: (self.view?.frame.size.width)! - 60, y: 20, width: 50, height: 50)
        undoButton.backgroundColor = flint
        undoButton.setImage(UIImage(named: "undo"), for: UIControl.State())
        undoButton.imageView?.contentMode = .center
        undoButton.addTarget(self, action: #selector(Board.undoLastMove), for: .touchUpInside)
        undoButton.tag = 30
        self.view?.addSubview(undoButton)
        undoButton.isHidden = true
        
        turnLabel = SKLabelNode(text: x)
        turnLabel.position = CGPoint(x: self.frame.width/2, y: yIsopin! * CGFloat(dim) + 150)
        turnLabel.fontColor = xColor
        turnLabel.fontName = mainFontName
        turnLabel.fontSize = 40
        turnLabel.zPosition = 3
        turnLabel.run(nodeAction)
        self.addChild(turnLabel)
        
        if aiGame{
            undoButton.removeFromSuperview()
            turnLabel.removeFromParent()
        }else{
            undoButton.isHidden = false
        }
    }
    
    func setUpMainAnimation(){
        let fadeOut = SKAction.scale(to: 1.10, duration: 0.5)
        let fadeIn = SKAction.scale(to: 1.0, duration: 0.5)
        let pulse = SKAction.sequence([fadeOut, fadeIn])
        let pulseForever = SKAction.repeatForever(pulse)
        nodeAction = pulseForever
    }
    
    
//MARK: - DRAWING THE BOARD
    
    func buildArrayOfNodes(){
        var set = Set<Node>()
        
        for theRow in 0...dim - 1{
            for column in 0...dim - 1 {
                let node = Node(column: column, row: theRow, theNodeType: NodeType.empty)
                if (theRow + 1) % 2 == 0 && (column + 1) % 2 != 0{  //if row is even and column is odd
                    node.nodeType = NodeType.o
                    node.sprite = SKSpriteNode(imageNamed: "O")
                    node.sprite?.name = o
                }else if (theRow + 1) % 2 != 0 && (column + 1) % 2 == 0{
                    node.nodeType = NodeType.x
                    node.sprite = SKSpriteNode(imageNamed: "X")
                    node.sprite?.name = x
                }else{
                    if theRow == 0 || theRow == dim - 1 || column == 0 || column == dim - 1{
                        node.nodeType = NodeType.empty
                    }else{
                        node.nodeType = NodeType.intersection
                    }
                }
                grid[column, theRow] = node
                set.insert(node)
                
            }
        }
        
        paintXsnOs(set)
    }
    
    func paintXsnOs(_ nodes: Set<Node>){
        for node in nodes{
            
            if let sprite = node.sprite {
                let position = pointForColumn(node.nodePos.column!, row: node.nodePos.row!)
                sprite.color = SKColor.red
                sprite.position = position
                if dim > 11{
                    sprite.size = CGSize(width: xIsopin!/1.1, height: yIsopin!/1.1)
                }else{
                    sprite.size = CGSize(width: xIsopin!/1.3, height: yIsopin!/1.3)
                }
                sprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                sprite.zPosition = 2
                sprite.setScale(0.0)
                gameLayer.addChild(sprite)
                let fadeOut = SKAction.scale(to: 1.3, duration: 0.5)
                let fadeIn = SKAction.scale(to: 1.0, duration: 0.5)
                sprite.run(SKAction.sequence([fadeOut, fadeIn]))
            }else{
                let position = pointForColumn(node.nodePos.column!, row: node.nodePos.row!)
                node.position = position
            }
        }
        animateNodes()
    }
    
    func pointForColumn(_ column: Int, row: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column) * xIsopin! + xIsopin!/2,
            y: CGFloat(row) * yIsopin! + bottomPadding)
    }
    
    func drawSquare(){
        var point = pointForColumn(1, row: dim - 1)
        point = self.convertPoint(toView: point)
        
        let x = xIsopin!
        let y = point.y + xIsopin!/2
        let width = (self.view?.frame.size.width)! - (xIsopin! * 2)
        let height = width
        let a = CGPoint(x: x, y: y)
        let b = CGPoint(x: x + width, y: y)
        let c = CGPoint(x: x + width, y: y + height)
        let d = CGPoint(x: x, y: y + height)
        
        let squarePath = UIBezierPath()
        squarePath.move(to: a)
        squarePath.addLine(to: b)
        squarePath.addLine(to: c)
        squarePath.addLine(to: d)
        squarePath.addLine(to: a)
        square = CAShapeLayer()
        square.path = squarePath.cgPath
        square.strokeColor = flint.cgColor
        square.fillColor = UIColor.clear.cgColor
        square.strokeEnd = 0.0
        view?.layer.addSublayer(square)
        
        let pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.duration = 1.0
        pathAnimation.fromValue = 0
        pathAnimation.toValue = 1
        pathAnimation.isRemovedOnCompletion = false
        pathAnimation.fillMode = CAMediaTimingFillMode.both
        pathAnimation.delegate = self
        square.add(pathAnimation, forKey: pathAnimation.keyPath)
        squareSound.play()

    }
    
    func animateNodes(){
        startActionForNodeType(x)
        let delayTime = DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            self.isUserInteractionEnabled = true
            if self.userTeam == .O && self.aiGame{
                self.performAIMove()
            }
        }
    }
    
    func startActionForNodeType(_ type: String){
        gameLayer.enumerateChildNodes(withName: type, using: {
            node, stop in
            node.run(self.nodeAction)
            // do something with node or stop
        })
    }
    
    func stopActionsOnGameLayer(_ type: String){
        gameLayer.enumerateChildNodes(withName: type, using: {
            node, stop in
            node.removeAllActions()
            node.run(SKAction.scale(to: 1.0, duration: 0.5))
            // do something with node or stop
        })
    }
    
    func isXTurn(){
        xTurn = true
    }
    
    func turnString() -> String{
        if xTurn{
            return x
        }else{
            return o
        }
    }
    
    func isCurrentUserTurn() ->Bool{
        return true
    }
    
    
//MARK: - TOUCHING AND DRAWING FUNCTIONS
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        guard !winner else {return}
        guard isCurrentUserTurn() else{return}
        for touch in touches {
            let location = touch.location(in: self.gameLayer)
            let touchedNode = self.atPoint(location)
            
            if touchedNode.name == x || touchedNode.name == o{
                
                if selectedNode.name == x && touchedNode.name == x{
                    guard xTurn else{return}
                    if isPotentialMatchingNode(selectedNode, secondSprite: touchedNode, type: x){
                        drawLineBetweenPoints(selectedNode.position, pointB: touchedNode.position, type: selectedNode.name!)
                    }
                    resetSelectedNode()
                }else if selectedNode.name == o && touchedNode.name == o{
                    guard !xTurn else{return}
                    if isPotentialMatchingNode(selectedNode, secondSprite: touchedNode, type: o){
                        drawLineBetweenPoints(selectedNode.position, pointB: touchedNode.position, type: selectedNode.name!)
                    }
                    resetSelectedNode()
                }else{
                    selectedNode.setScale(1.0)
                    selectedNode = touchedNode as! SKSpriteNode
                    if touchedNode.name == x && xTurn{
                        selectedNode.setScale(1.25)
                        startPoint = selectedNode.position
                    }else if touchedNode.name == o && !xTurn{
                        selectedNode.setScale(1.25)
                        startPoint = selectedNode.position
                    }
                }
            }else{
                resetSelectedNode()
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isCurrentUserTurn() else{return}
        for touch: AnyObject in touches{
            touchedLocations.append(touch.location(in: self.gameLayer))
            let location = touch.location(in: self.gameLayer)
            let touchedNode = self.atPoint(location)
            
            if !pointsConnected && startPoint != CGPoint.zero{
                if touchedNode.name == x && xTurn && touchedNode != selectedNode{
                    if isPotentialMatchingNode(selectedNode, secondSprite: touchedNode, type: ""){
                        nextPoint = touchedNode.position
                        drawPotentialLineBetweenPoints(startPoint, pointB: nextPoint, type: x)
                        pointsConnected = true
                        return
                    }else{
                        drawPotentialLineBetweenPoints(startPoint, pointB: location, type: "N")
                    }
                }else if touchedNode.name == o && !xTurn{
                    if isPotentialMatchingNode(selectedNode, secondSprite: touchedNode, type: ""){
                        nextPoint = touchedNode.position
                        drawPotentialLineBetweenPoints(startPoint, pointB: nextPoint, type: o)
                        pointsConnected = true
                        return
                    }else{
                        drawPotentialLineBetweenPoints(startPoint, pointB: location, type: "N")
                    }
                }else{
                    nextPoint = location
                    drawPotentialLineBetweenPoints(startPoint, pointB: nextPoint, type: "")
                }
            }else if touchedNode == selectedNode{
                pointsConnected = false
                potentialShapeNode.removeFromSuperlayer()
                return
            }else{
                
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isCurrentUserTurn() else{return}
        potentialShapeNode.removeFromSuperlayer()
        guard pointsConnected == true else{
            resetSelectedNode()
            touchedLocations.removeAll()
            return
        }
        pointsConnected = false
        startPoint = CGPoint.zero
        for theTouch: AnyObject in touches{
            touchedLocations.append(theTouch.location(in: self.gameLayer))
        }
        for location: CGPoint in touchedLocations {
            let touchedNode = self.atPoint(location)
            if selectedNode.name == x && touchedNode.name == x{
                guard xTurn else{touchedLocations.removeAll(); return}
                if isPotentialMatchingNode(selectedNode, secondSprite: touchedNode, type: x){
                    drawLineBetweenPoints(selectedNode.position, pointB: touchedNode.position, type: selectedNode.name!)
                    cleanUpMove()
                    return
                }
            }else if selectedNode.name == o && touchedNode.name == o{
                guard !xTurn else{touchedLocations.removeAll(); return}
                if isPotentialMatchingNode(selectedNode, secondSprite: touchedNode, type: o){
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
    
    fileprivate func cleanUpMove(){
        resetSelectedNode()
        touchedLocations.removeAll()
    }
    
    fileprivate func resetSelectedNode(){
        selectedNode.setScale(1.0)
        selectedNode = SKSpriteNode()
    }
    
    func isPotentialMatchingNode(_ firstSprite: SKSpriteNode, secondSprite: SKNode, type: String) -> Bool {
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
                    let intersection = gridItem(column: interCol, row: interRow)
                    if intersection?.nodeType == NodeType.intersection && intersection?.nodePos.ptWho == ""{
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
    
    func convertSpritesToPoints(_ firstSprite: SKSpriteNode, secondSprite: SKNode) -> (column: Float, row: Float, column2: Float, row2: Float) {
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
    
    func drawPotentialLineBetweenPoints(_ pointA: CGPoint, pointB: CGPoint, type: String) {
        var pointA = pointA, pointB = pointB
        potentialShapeNode.removeFromSuperlayer()
        pointA = self.convertPoint(toView: pointA)
        pointB = self.convertPoint(toView: pointB)
        let newPath = UIBezierPath()
        newPath.move(to: pointA)
        newPath.addLine(to: pointB)
        potentialShapeNode.path = newPath.cgPath
        potentialShapeNode.strokeColor = UIColor(white: 0.6, alpha: 0.8).cgColor
        potentialShapeNode.lineWidth = 3
        view?.layer.addSublayer(potentialShapeNode)
    }
    
    func drawLineBetweenPoints(_ pointA: CGPoint,pointB: CGPoint, type: String){
        var pointA = pointA, pointB = pointB
        let (columnA, rowA, columnB, rowB) = calculateColumnsAndRows(pointA, pointB: pointB)
        recentCoordinates = RecentCoordinates(columnA: columnA, rowA: rowA, columnB: columnB, rowB: rowB)
        var match = false
        var matchedLine = LineShapeLayer(columnA: 0, rowA: 0, columnB: 0, rowB: 0, team: "N")
        pointA = self.convertPoint(toView: pointA)
        pointB = self.convertPoint(toView: pointB)
        let path = matchedLine.createPath(pointA: pointA, pointB: pointB)
        
        var lineArray = xLines
        var strokeColor = xColor.cgColor
        if type == o{
            lineArray = oLines
            strokeColor = oColor.cgColor
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
            view?.layer.addSublayer(shapeNode)
            animateLine(shapeNode, type: .normal)
            appendLineArrays(shapeNode)
            lastMove = .singleLine
            previousMoveDetails.newAppendedLine = shapeNode
        }
        undoButton.isUserInteractionEnabled = true
        undoButton.backgroundColor = oColor
        if type == x{
            xSound.play()
        }else{
            oSound.play()
        }
    }
    
    func loopThroughCoordinates(_ lineShapeLayer: LineShapeLayer, matchedLine: LineShapeLayer, path: CGPath, columnA: Int, rowA: Int, columnB: Int, rowB: Int, match: Bool) -> (match:Bool, matchedLine: LineShapeLayer, lineDelete: LineShapeLayer){
        var matchedLine = matchedLine, match = match
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
                    _ = createLineCopy(lineShapeLayer)
                    lastMove = .appendedLine
                    matchedLine = lineShapeLayer
                    let tempLine = LineShapeLayer(columnA: 0, rowA: 0, columnB: 0, rowB: 0, team: "N", path: path, color: matchedLine.strokeColor!)
                    view?.layer.addSublayer(tempLine)
                    animateLine(tempLine, type: .delete)
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
    
    func appendLineArrays(_ shapeNode : LineShapeLayer){
        if shapeNode.team == x{
            xLines.append(shapeNode)
        }else{
            oLines.append(shapeNode)
        }
    }
    
    func deleteLineFromArrays(_ lineToDelete: LineShapeLayer){
        if lineToDelete.team == x{
            if let index = xLines.index(of: lineToDelete){
                xLines.remove(at: index)
            }
        }else if lineToDelete.team == o{
            if let index = oLines.index(of: lineToDelete){
                oLines.remove(at: index)
            }
        }
        lineToDelete.removeFromSuperlayer()
    }
    
    func createLineAtPoints(_ pointA: CGPoint, pointB: CGPoint) -> CGPath{
        let ref = CGMutablePath()
        ref.move(to: CGPoint(x: pointA.x, y: pointA.y))
        ref.addLine(to: CGPoint(x: pointB.x, y: pointB.y))
        return ref
    }
    
    func createLineCopy(_ lineShapeLayer: LineShapeLayer) -> LineShapeLayer{
        let line = LineShapeLayer(columnA: 0, rowA: 0, columnB: 0, rowB: 0, team: "N")
        line.copyLineValues(lineShapeLayer)
        previousMoveDetails.oldLines.append(line)
        return line
    }
    
    func switchTurns(){
        guard !winner else {return}
        if xTurn{
            xTurn = false
            turnLabel.text = o
            turnLabel.fontColor = oColor
            stopActionsOnGameLayer(x)
            startActionForNodeType(o)
            if userTeam == .X{
                performAIMove()
            }
            
        }else{
            xTurn = true
            turnLabel.text = x
            turnLabel.fontColor = xColor
            stopActionsOnGameLayer(o)
            startActionForNodeType(x)
            if userTeam == .O{
                performAIMove()
            }
        }
    }
    
    func performAIMove(){
        guard aiGame else {return}
        self.isUserInteractionEnabled = false
        let lineAI = LineAI(grid: grid, difficulty: difficulty, userTeam: userTeam)
        let (coord, node) = lineAI.calculateAIMove()
        guard coord != nil || node != nil else {return}
        let pointA = pointForColumn(coord!.columnA, row: coord!.rowA)
        let pointB = pointForColumn(coord!.columnB, row: coord!.rowB)
        let interNode = gridItem(column: (node?.nodePos.column)!, row: (node?.nodePos.row)!)
        self.isUserInteractionEnabled = true
        switch userTeam{
        case .X:
            interNode?.nodePos.ptWho = o
            OperationQueue.main.addOperation { () -> Void in
                self.drawLineBetweenPoints(pointA, pointB: pointB, type: o)
            }
        case .O:
            interNode?.nodePos.ptWho = x
            OperationQueue.main.addOperation { () -> Void in
                self.drawLineBetweenPoints(pointA, pointB: pointB, type: x)
            }

        }        
    }

    
 //MARK: - LINE ANIMATIONS
    
    func animateLine(_ line: LineShapeLayer, type: LineAnimationOperation.AnimationType){
        self.isUserInteractionEnabled = false
        let operationQueue = OperationQueue.main
        let animationOp = LineAnimationOperation(line: line, type: type)
        animationOp.completionBlock = {
            self.isUserInteractionEnabled = true
            self.switchTurns()
        }
        switch type{
        case .normal:
            operationQueue.addOperation(animationOp)
        case .delete:
            operationQueue.addOperation(animationOp)
        }
    }
    
    func animateWidth(_ line: LineShapeLayer){
        let animation = CABasicAnimation(keyPath: "lineWidth")
        animation.toValue = 6
        animation.duration = 0.25
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut) // animation curve is Ease Out
        animation.autoreverses = true
        animation.fillMode = CAMediaTimingFillMode.both // keep to value after finishing
        animation.isRemovedOnCompletion = false // don't remove after finishing
        line.add(animation, forKey: animation.keyPath)
    }
    
    func animateWidthThenDelete(_ line: LineShapeLayer){
        let animation = CABasicAnimation(keyPath: "lineWidth")
        animation.toValue = 6
        animation.duration = 0.25
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut) // animation curve is Ease Out
        animation.autoreverses = true
        animation.delegate = line
        animation.fillMode = CAMediaTimingFillMode.both // keep to value after finishing
        animation.isRemovedOnCompletion = false // don't remove after finishing
        line.add(animation, forKey: animation.keyPath)
    }

    
    //MARK: - WINNING FUNCTIONS
    
    func checkForWinner(_ line: LineShapeLayer){
        //check each coordinate on the newly appended line to see if it touches both ends of the board
        if line.team == x{
            loopCoordinatesForXWinner(line)
        }else if line.team == o{
            loopCoordinatesForOWinner(line)
        }
    }
    
    func loopCoordinatesForXWinner(_ line: LineShapeLayer){
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
    
    func loopCoordinatesForOWinner(_ line: LineShapeLayer){
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
    
    func declareWinner(_ winningTeam: String){
        winner = true
        if winningTeam == userTeam.rawValue{
            cheerSound.play()
        }else{
            loseSound.play()
        }

        let alertController = UIAlertController(title: "\(winningTeam) Wins", message: "Play again?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Okay", style: .cancel) { (action) in
            OperationQueue.main.addOperation({ () -> Void in
                self.gameover()
            })
        }
        alertController.addAction(cancelAction)
        self.view?.window?.rootViewController?.present(alertController, animated: true, completion: nil)
        
    }
    
    
    //MARK: - UNDO MOVE
    
    @objc func undoLastMove(){
        buttonSoundEffect.play()
        undoButton.backgroundColor = flint
        undoButton.isUserInteractionEnabled = false

        switch lastMove{
        case .singleLine:
            undoSingleLine()
            break
        case .appendedLine:
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
    
    fileprivate func removeLastLineFromArray(){
        if xTurn{
            oLines.removeLast()
        }else{
            xLines.removeLast()
        }
    }
    
    fileprivate func resetIntersection(){
        let intersection = gridItem(column: lastIntersection.col, row: lastIntersection.row)
        intersection?.nodePos.ptWho = ""
    }
    
    func undoAppendedLine(){
        guard !previousMoveDetails.moveUnDid else{return}
        var lineArray = lineArrayForLastMove()
        let index = lineArray.index(of: previousMoveDetails.newAppendedLine)
        let lineToRemove = lineArray[index!]
        lineToRemove.removeFromSuperlayer()
        lineArray.remove(at: index!)
        for line in previousMoveDetails.oldLines{
            lineArray.append(line)
            view?.layer.addSublayer(line)
        }
        
        if xTurn{
            oLines = lineArray
        }else{
            xLines = lineArray
        }
        resetIntersection()
        previousMoveDetails.moveUnDid = true
        switchTurns()
    }
    
    fileprivate func lineArrayForLastMove() -> [LineShapeLayer]{
        if xTurn{
            return oLines
        }else{
            return xLines
        }
    }

    
    //MARK: - RESETTING GAME
    
    func gameover(){
        if !UserDefaults.standard.bool(forKey: "adsRemoved"){
            Chartboost.showInterstitial(CBLocationGameOver)
        }
        
        resetBoard()
    }
    
    func resetBoard(){
        //delete all objects on the board
        removeViews()
        tranistionToNewBoard()
    }
    
    func tranistionToNewBoard(){
        let secondScene = Board(size: self.size, theDim: dim, theRows: rows, userTeam: userTeam, aiGame: aiGame, difficulty: difficulty)
        let transition = SKTransition.crossFade(withDuration: 0.75)
        secondScene.scaleMode = SKSceneScaleMode.aspectFill
        self.scene!.view?.presentScene(secondScene, transition: transition)
    }
    
    
    //MARK: - SUPPORT FUNCTIONS
    
    //Takes a point and returns the column and row for that point
    func calculateColumnsAndRows(_ pointA: CGPoint, pointB: CGPoint) -> (columnA: Int, rowA: Int, columnB: Int, rowB: Int){
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
    
    func convertPoint(_ point: CGPoint) -> (success: Bool, column: Float, row: Float) {
        guard let xIsopin = xIsopin, let yIsopin = yIsopin else { return (false, 0, 0) }
        if point.x >= 0 && point.x < CGFloat(dim) * xIsopin &&
            point.y >= 0 && point.y < CGFloat(dim) * yIsopin + bottomPadding {
                return (true, Float((point.x - (xIsopin/2)) / xIsopin), Float((point.y - bottomPadding) / yIsopin))
        } else {
            return (false, 0, 0)  // invalid location
        }
    }
    
    func gridItem(column: Int, row: Int) -> Node? {
        assert(column >= 0 && column <= dim)
        assert(row >= 0 && row <= dim)
        return grid[column, row]
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
    
    override func removeViews(){
        self.removeAllChildren()
        self.removeAllActions()
        removeLines()
        nodeX.removeAll()
        nodeO.removeAll()
        xLines.removeAll()
        oLines.removeAll()
        square.removeFromSuperlayer()
        restartButton.removeFromSuperview()
        backButton.removeFromSuperview()
        undoButton.removeFromSuperview()
    }
    
    func removeLines(){
        for shape in xLines{
            shape.removeFromSuperlayer()
        }
        for shape in oLines{
            shape.removeFromSuperlayer()
        }
    }
    
    //MARK: - BUTTON FUNCTIONS
    
    @objc func restartPressed(){
        buttonSoundEffect.play()
        resetBoard()
    }
    
    @objc func mainPressed(){
        buttonSoundEffect.play()
        removeViews()
        transitionToMainScene()
    }
    
    func transitionToMainScene(){
        let mainScene = MainScene(size: self.size)
        self.scene?.view?.presentScene(mainScene)
    }
}

extension Board: CAAnimationDelegate {

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        boardSound.player.rate = 0.5
        boardSound.play()
    }

}
