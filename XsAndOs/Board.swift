//
//  Board.swift
//  XsAndOs
//
//  Created by Derik Flanary on 11/5/15.
//  Copyright © 2015 Derik Flanary. All rights reserved.
//

import SpriteKit

var dim = 11
let bottomPadding : CGFloat = 100

class Board: SKScene {
    
    var nodeX = [Nodes]()
    var nodeO = [Nodes]()
//    Nodes[,] Nodez;     // an array of Nodes: pts color screen position and array pos
    var yIsopin : CGFloat?    // distance between nodes Vertical
    var xIsopin : CGFloat?
    let gameLayer = SKNode()
    var grid = Array2D<Nodes>(columns: dim, rows: dim)
    
    var selectedNode = SKSpriteNode()
    var secondSelectedNode = SKSpriteNode()
    
    override init(size: CGSize) {
        super.init(size: size)
        
        self.backgroundColor = SKColor.whiteColor()
        gameLayer.position = CGPointMake(0, 0)
        addChild(gameLayer)
        
        xIsopin = self.frame.size.width / CGFloat(dim)
        yIsopin = xIsopin
        print(xIsopin, yIsopin)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        startGame()
        
    }
    
    func startGame(){
        
        
    
        buildArrayOfNodes()
    }
    
    func buildArrayOfNodes(){
        var set = Set<Nodes>()
        
        for  var theRow = 0; theRow < dim; ++theRow{
            for var column = 0; column < dim; ++column{
                let node = Nodes(column: column, row: theRow, theNodeType: NodeType.Empty)
               
                
                if (theRow + 1) % 2 == 0 && (column + 1) % 2 != 0{  //if row is even and column is odd
                    node.nodeType = NodeType.O
                    node.sprite = SKSpriteNode(imageNamed: "O")
                    node.sprite?.name = "O"
                }else if (theRow + 1) % 2 != 0 && (column + 1) % 2 == 0{
                    node.nodeType = NodeType.X
                    node.sprite = SKSpriteNode(imageNamed: "X")
                    node.sprite?.name = "X"
                }else{
                    if theRow == 0 || theRow == dim - 1 || column == 0 || column == dim - 1{
                        node.nodeType = NodeType.Empty
                    }else{
                        node.nodeType = NodeType.Intersection
                    }
                }
                grid[column,theRow] = node
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
                sprite?.size = CGSizeMake(xIsopin!/2, yIsopin!/2)
                sprite?.anchorPoint = CGPointMake(0, 0)
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
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        
        for touch in touches {
            let location = touch.locationInNode(self.gameLayer)
            let touchedNode = self.nodeAtPoint(location)
            
            if touchedNode.name == "X" || touchedNode.name == "O"{
                
                if selectedNode.name == "X" && touchedNode.name == "X"{
                    if isPotentialMatchingNode(selectedNode, secondSprite: touchedNode, type: "X"){
                        drawLineBetweenPoints(selectedNode.position, pointB: touchedNode.position, type: selectedNode.name!)
                        
                    }
                    selectedNode.setScale(1.0)
                    selectedNode = SKSpriteNode()
                    
                }else if selectedNode.name == "O" && touchedNode.name == "O"{
                    if isPotentialMatchingNode(selectedNode, secondSprite: touchedNode, type: "O"){
                        drawLineBetweenPoints(selectedNode.position, pointB: touchedNode.position, type: selectedNode.name!)
                        
                    }
                    selectedNode.setScale(1.0)
                    selectedNode = SKSpriteNode()
                    
                }else{
                    selectedNode.setScale(1.0)
                    selectedNode = touchedNode as! SKSpriteNode
                    selectedNode.setScale(1.25)
                    print(selectedNode.position)
                }
                
            }else{
                selectedNode.setScale(1.0)
                
                var (success, column, row) = convertPoint(location)
                if success{
                    column = round(column)
                    row = round(row)
                    let node = gridItemAtColumn(Int(column), row: Int(row))
                    print(node?.nodeType)
                }
            }
        }
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
    
    func drawLineBetweenPoints(pointA: CGPoint, pointB: CGPoint, type: String){
        let path = createLineAtPoints(pointA, pointB: pointB)
        
        let shapeNode = SKShapeNode()
        shapeNode.path = path
        shapeNode.name = "line"
        if type == "X"{
            shapeNode.strokeColor = UIColor.redColor()
        }else{
            shapeNode.strokeColor = UIColor.blueColor()
        }
        shapeNode.lineWidth = 4
        shapeNode.zPosition = 0
        shapeNode.userInteractionEnabled = false
        gameLayer.addChild(shapeNode)
        
    }
    
    func createLineAtPoints(pointA: CGPoint, pointB: CGPoint) -> CGPathRef{
        let ref = CGPathCreateMutable()
        CGPathMoveToPoint(ref, nil, pointA.x + selectedNode.frame.size.width/2, pointA.y + selectedNode.frame.size.height/2)
        CGPathAddLineToPoint(ref, nil, pointB.x + selectedNode.frame.size.width/2, pointB.y + selectedNode.frame.size.height/2)
        
        
        return ref
        
    }
    
    func isPotentialMatchingNode(firstSprite: SKSpriteNode, secondSprite: SKNode, type: String) -> Bool{
        
        var (success, column, row) = convertPoint(firstSprite.position)
        if success {
            column = round(column)
            row = round(row)
            print(round(column), round(row))
//                            let node = gridItemAtColumn(Int(column), row: Int(row))
        }
        var (success2, column2, row2) = convertPoint(secondSprite.position)
        if success2{
            column2 = round(column2)
            row2 = round(row2)
            print(column2, row2)
        }
        
        if column == column2 || column - column2 == -2 || column - column2 == 2{
            print("potential column match")
            
            if row == row2 || row - row2 == -2 || row - row2 == 2 {
                print("potential row match")
                
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
                        print("drawing line")
                        return true
                    }
                }
            }
        }
        return false
    
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }

}
