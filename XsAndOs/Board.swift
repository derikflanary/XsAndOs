//
//  Board.swift
//  XsAndOs
//
//  Created by Derik Flanary on 11/5/15.
//  Copyright © 2015 Derik Flanary. All rights reserved.
//

import SpriteKit

var dim = 7

class Board: SKScene {
    
    var nodeX = [Nodes]()
    var nodeO = [Nodes]()
//    Nodes[,] Nodez;     // an array of Nodes: pts color screen position and array pos
    var yIsopin : CGFloat?    // distance between nodes Vertical
    var xIsopin : CGFloat?
    let gameLayer = SKNode()
    var grid = Array2D<Nodes>(columns: dim, rows: dim)
    
    override init(size: CGSize) {
        super.init(size: size)
        
        self.backgroundColor = SKColor.whiteColor()
        gameLayer.position = CGPointMake(0, 100)
        addChild(gameLayer)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        startGame()
        
    }
    
    func startGame(){
        xIsopin = 50
        yIsopin = 50
    
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
                }else if (theRow + 1) % 2 != 0 && (column + 1) % 2 == 0{
                    node.nodeType = NodeType.X
                    node.sprite = SKSpriteNode(imageNamed: "X")
                }else{
                    if theRow == 0 || theRow == dim - 1 || column == 0 || column == dim - 1{
                        node.nodeType = NodeType.Intersection
                    }else{
                        node.nodeType = NodeType.Empty
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
                let position = pointForColumn(node.nodePos.column!, row: node.nodePos.row!)
                let sprite = node.sprite
                sprite?.color = SKColor.redColor()
                sprite?.position = position
//                sprite?.size = CGSizeMake(25, 25)
                sprite?.anchorPoint = CGPointMake(0, 0)
                gameLayer.addChild(sprite!)

                
            }
            
        }
            print(self.children)
    }
    
    func pointForColumn(column: Int, row: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column) * xIsopin! + xIsopin!/2,
            y: CGFloat(row) * yIsopin! + yIsopin!/2)
    }
    
    func gridItemAtColumn(column: Int, row: Int) -> Nodes? {
        assert(column >= 0 && column < dim)
        assert(row >= 0 && row < dim)
        return grid[column, row]
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }

}
