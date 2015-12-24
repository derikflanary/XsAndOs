//
//  Board.swift
//  XsAndOs
//
//  Created by Derik Flanary on 11/5/15.
//  Copyright © 2015 Derik Flanary. All rights reserved.
//

import SpriteKit

//var dim = 9
let bottomPadding : CGFloat = 100

class Board: SKScene {
    
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
    var xLines = [LineShapeNode]()
    var oLines = [LineShapeNode]()
    var movingTouches = Set<UITouch>()
    var touchedLocations = [CGPoint]()
    var turnLabel = SKLabelNode()
    
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
        startGame()
    }
    
    
//GAME SETUP
    func startGame(){
        self.backgroundColor = SKColor.whiteColor()
        gameLayer.position = CGPointMake(0, 0)
        addChild(gameLayer)
        
        xTurn = true
        
        buildArrayOfNodes()
        drawSquare()
        
        let restartButton = UIButton()
        restartButton.frame = CGRectMake((self.view?.frame.size.width)!/2 - 50, 20, 100, 30)
        restartButton.setTitleColor(UIColor.darkTextColor(), forState: .Normal)
        restartButton.setTitleColor(UIColor.lightTextColor(), forState: .Highlighted)
        restartButton.setTitle("Restart", forState: UIControlState.Normal)
        restartButton.addTarget(self, action: "restartPressed", forControlEvents: .TouchUpInside)
        restartButton.tag = 10
        self.view?.addSubview(restartButton)
        
        let backButton = UIButton()
        backButton.frame = CGRectMake(10, 20, 50, 30)
        backButton.setTitle("Main", forState: .Normal)
        backButton.setTitleColor(UIColor(white: 0.4, alpha: 1), forState: .Normal)
        backButton.setTitleColor(UIColor(white: 0.7, alpha: 1), forState: .Highlighted)
        backButton.addTarget(self, action: "mainPressed", forControlEvents: .TouchUpInside)
        backButton.tag = 20
        self.view?.addSubview(backButton)
        
        turnLabel = SKLabelNode(text: "X")
        turnLabel.position = CGPointMake(self.frame.width/2, yIsopin! * CGFloat(dim) + 150)
        turnLabel.fontColor = SKColor.blackColor()
        turnLabel.zPosition = 3
        self.addChild(turnLabel)
        
    }
    
//DRAWING THE BOARD
    func buildArrayOfNodes(){
        var set = Set<Nodes>()
        
        for  var theRow = 0; theRow < dim; ++theRow{
            for var column = 0; column < dim; ++column{
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
    
//TOUCHING AND DRAWING FUNCTIONS
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        
        for touch in touches {
            let location = touch.locationInNode(self.gameLayer)
            let touchedNode = self.nodeAtPoint(location)
            
            if touchedNode.name == "X" || touchedNode.name == "O"{
                
                if selectedNode.name == "X" && touchedNode.name == "X"{
                    if !xTurn{
                        return
                    }

                    selectedNode.setScale(1.0)
                    if isPotentialMatchingNode(selectedNode, secondSprite: touchedNode, type: "X"){
                        drawLineBetweenPoints(selectedNode.position, pointB: touchedNode.position, type: selectedNode.name!)
                        xTurn = false
                        turnLabel.text = "O"
                    }
                    selectedNode = SKSpriteNode()
                    
                    
                }else if selectedNode.name == "O" && touchedNode.name == "O"{
                    if xTurn{
                        return
                    }
                    selectedNode.setScale(1.0)
                    if isPotentialMatchingNode(selectedNode, secondSprite: touchedNode, type: "O"){
                        drawLineBetweenPoints(selectedNode.position, pointB: touchedNode.position, type: selectedNode.name!)
                        xTurn = true
                        turnLabel.text = "X"
                    }
                    selectedNode = SKSpriteNode()
                    
                    
                }else{
                    selectedNode.setScale(1.0)
                    selectedNode = touchedNode as! SKSpriteNode
                    if touchedNode.name == "X" && xTurn{
                        selectedNode.setScale(1.25)
                    }else if touchedNode.name == "O" && !xTurn{
                        selectedNode.setScale(1.25)
                    }
                }
                
            }else{
                selectedNode.setScale(1.0)
                selectedNode = SKSpriteNode()
                var (success, column, row) = convertPoint(location)
                if success{
                    column = round(column)
                    row = round(row)

                }
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch: AnyObject in touches{
            touchedLocations.append(touch.locationInNode(self.gameLayer))
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for theTouch: AnyObject in touches{
            touchedLocations.append(theTouch.locationInNode(self.gameLayer))
        }
        
        for location: CGPoint in touchedLocations {
            //Get the location of your touch
//            let location = touch.locationInNode(self.gameLayer)
            let touchedNode = self.nodeAtPoint(location)
            
            if selectedNode.name == "X" && touchedNode.name == "X"{
                if !xTurn{
                    touchedLocations.removeAll()
                    return
                }
                
                
                if isPotentialMatchingNode(selectedNode, secondSprite: touchedNode, type: "X"){
                    drawLineBetweenPoints(selectedNode.position, pointB: touchedNode.position, type: selectedNode.name!)
                    xTurn = false
                    turnLabel.text = "O"
                    selectedNode.setScale(1.0)
                    selectedNode = SKSpriteNode()
                    touchedLocations.removeAll()
                    return
                }
                
            }else if selectedNode.name == "O" && touchedNode.name == "O"{
                if xTurn{
                    touchedLocations.removeAll()
                    return
                }
                
                if isPotentialMatchingNode(selectedNode, secondSprite: touchedNode, type: "O"){
                    drawLineBetweenPoints(selectedNode.position, pointB: touchedNode.position, type: selectedNode.name!)
                    xTurn = true
                    turnLabel.text = "X"
                    selectedNode.setScale(1.0)
                    selectedNode = SKSpriteNode()
                    touchedLocations.removeAll()
                    return
                }
            
            }else{
                touchedLocations.removeAll()
            }
        }
        touchedLocations.removeAll()

    }
    
    func isPotentialMatchingNode(firstSprite: SKSpriteNode, secondSprite: SKNode, type: String) -> Bool{
        
        var (success, column, row) = convertPoint(firstSprite.position)
        if success {
            column = round(column)
            row = round(row)
            
        }
        var (success2, column2, row2) = convertPoint(secondSprite.position)
        if success2{
            column2 = round(column2)
            row2 = round(row2)
            //            print(column2, row2)
        }
        
        if column == column2 || column - column2 == -2 || column - column2 == 2{
            //            print("potential column match")
            
            if row == row2 && column != column2 || row - row2 == -2 || row - row2 == 2 {
                //                print("potential row match")
                
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
                        
                        return true
                    }
                }
            }
        }
        return false
        
    }
    
    
    func drawLineBetweenPoints(pointA: CGPoint, pointB: CGPoint, type: String){
        
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
        
        var match = false
        var matchedLine = LineShapeNode(columnA: 0, rowA: 0, columnB: 0, rowB: 0, team: "N")
        let path = createLineAtPoints(pointA, pointB: pointB)
        
        if type == "X"{
        //check every coordinate in xlines to see if any existing lines touch the new line then add new line
            for lineShapeNode in xLines{
                
                for coordinate in lineShapeNode.coordinates{
                    
                    if coordinate.columnA == columnA && coordinate.rowA == rowA || coordinate.columnA == columnB && coordinate.rowA == rowB || coordinate.columnB == columnA && coordinate.rowB == rowA || coordinate.columnB == columnB && coordinate.rowB == rowB {

                        if match{
                            //If the new line connects two existing lines, add the second path to the first one
                            lineShapeNode.appendPath(matchedLine.path!)
                            for coordinate in matchedLine.coordinates{
                                lineShapeNode.addCoordinate(coordinate.columnA!, rowA: coordinate.rowA!, columnB: coordinate.columnB!, rowB: coordinate.rowB!)
                            }
                            
                            //remove the extra line
                            if matchedLine.team != "N"{
                                if let index = xLines.indexOf(matchedLine){
                                    xLines.removeAtIndex(index)
                                }
                            }
                            if checkForWinner(lineShapeNode){
                                self.declareWinner(lineShapeNode.team!)
                                print("X wins")
                            }
                            
                        }else{
                            //If the first coordinate matches, add the path to the line and then if will keep looking if the other coordinate on the path matches another line and if so it will add this line to that line.
                            match = true
                            matchedLine = lineShapeNode
                            lineShapeNode.appendPath(path)
                            lineShapeNode.addCoordinate(columnA, rowA: rowA, columnB: columnB, rowB: rowB)
                            if checkForWinner(lineShapeNode){
                                self.declareWinner(lineShapeNode.team!)
                                print("X wins")
                            }
                        }
                    }
                }
            }
            
            //If new line doesn't touch an existing line, make a new line
            if !match{
                let shapeNode = LineShapeNode(columnA: columnA, rowA: rowA, columnB: columnB, rowB: rowB, team: type)
                shapeNode.setShapeAspects(path)
                shapeNode.strokeColor = UIColor.redColor()
                addChild(shapeNode)
                xLines.append(shapeNode)
            }
            
        //Repeat for O's
        }else if type == "O"{
            
            for lineShapeNode in oLines{
                
                for coordinate in lineShapeNode.coordinates{
                    
                    if coordinate.columnA == columnA && coordinate.rowA == rowA || coordinate.columnA == columnB && coordinate.rowA == rowB || coordinate.columnB == columnA && coordinate.rowB == rowA || coordinate.columnB == columnB && coordinate.rowB == rowB {
           
                        if match{
                            lineShapeNode.appendPath(matchedLine.path!)
                            for coordinate in matchedLine.coordinates{
                                lineShapeNode.addCoordinate(coordinate.columnA!, rowA: coordinate.rowA!, columnB: coordinate.columnB!, rowB: coordinate.rowB!)
                            }
                            if matchedLine.team != "N"{
                                if let index = oLines.indexOf(matchedLine){
                                    oLines.removeAtIndex(index)
                                }
                                
                            }
                            if checkForWinner(lineShapeNode){
                                print("O Wins")
                                self.declareWinner(lineShapeNode.team!)
                            }
                            
                        }else{
                            match = true
                            matchedLine = lineShapeNode
                            lineShapeNode.appendPath(path)
                            lineShapeNode.addCoordinate(columnA, rowA: rowA, columnB: columnB, rowB: rowB)
                        
                            if checkForWinner(lineShapeNode){
                                print("O Wins")
                                self.declareWinner(lineShapeNode.team!)
                            }
                            
                        }
                    }
                }
            }
            
            if !match{
                let shapeNode = LineShapeNode(columnA: columnA, rowA: rowA, columnB: columnB, rowB: rowB, team: type)
                shapeNode.setShapeAspects(path)
                shapeNode.strokeColor = UIColor.blueColor()
                addChild(shapeNode)
                oLines.append(shapeNode)
            }else{
                
            }
        }
        
    }
    
    func createLineAtPoints(pointA: CGPoint, pointB: CGPoint) -> CGPathRef{
        let ref = CGPathCreateMutable()
        CGPathMoveToPoint(ref, nil, pointA.x, pointA.y)
        CGPathAddLineToPoint(ref, nil, pointB.x, pointB.y)
        return ref
    }
    
//WINNING FUNCTIONS
    func checkForWinner(line: LineShapeNode) -> Bool{
        
        var edgeOne = false
        var edgeTwo = false
        
        //check each coordinate on the newly appended line to see if it touches both ends of the board
        if line.team == "X"{
            for coordinate in line.coordinates{
//                print(coordinate)
                if coordinate.rowA == dim - 1 || coordinate.rowB == dim - 1{
                    edgeOne = true
                }
                
                if coordinate.rowA == 0 || coordinate.rowB == 0{
                    edgeTwo = true
                }
                
                if edgeOne && edgeTwo{
                    return true
                }
            }
            return false
          
        }else if line.team == "O"{
            for coordinate in line.coordinates{
//                print(coordinate)
                if coordinate.columnA == dim - 1 || coordinate.columnB == dim - 1{
                    edgeOne = true
                }
                
                if coordinate.columnA == 0 || coordinate.columnB == 0{
                    edgeTwo = true
                }
                
                if edgeOne && edgeTwo{
                    return true
                }
            }
            return false
        }
        
        return false
    }
    
    func declareWinner(winningTeam: String){
        let alertController = UIAlertController(title: "\(winningTeam) Wins", message: "Play again?", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Okay", style: .Cancel) { (action) in
            self.resetBoard()
        }
        alertController.addAction(cancelAction)
        self.view?.window?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
    }

//RESETTING GAME
    
    func resetBoard(){
        //delete all objects on the board
        self.removeAllChildren()
        self.removeAllActions()
        nodeX.removeAll()
        nodeO.removeAll()
        xLines.removeAll()
        oLines.removeAll()
        grid.removeArray()
        self.view?.viewWithTag(10)?.removeFromSuperview()
        self.view?.viewWithTag(20)?.removeFromSuperview()
        
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
    
//BUTTON FUNCTIONS
    
    func restartPressed(){
        resetBoard()
    }
    
    func mainPressed(){
        let mainScene = GameScene(size: self.size)
        let transition = SKTransition.crossFadeWithDuration(0.75)
        mainScene.scaleMode = .AspectFill
        self.scene?.view?.presentScene(mainScene, transition: transition)
        self.view?.viewWithTag(10)?.removeFromSuperview()
        self.view?.viewWithTag(20)?.removeFromSuperview()
    }
}
