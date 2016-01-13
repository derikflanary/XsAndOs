//
//  DotsScene.swift
//  XsAndOs
//
//  Created by Derik Flanary on 1/12/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation
import SpriteKit

class DotsScene: XandOScene {
    
    var dim : Int
    var nodez = [Nodes]()
    var yIsopin : CGFloat?    // distance between nodes Vertical
    var xIsopin : CGFloat?
    let gameLayer = SKNode()
    var grid : Array2D<Nodes>
    
    init(theDim: Int, size: CGSize) {
        dim = theDim
        grid = Array2D(columns: dim, rows: dim)
        super.init(size: size)
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        self.backgroundColor = SKColor.whiteColor()
        gameLayer.position = CGPointMake(0, 0)
        addChild(gameLayer)
        xIsopin = self.frame.size.width / CGFloat(dim)
        yIsopin = xIsopin
        buildArrayOfNodes()

    }
    
    //DRAWING THE BOARD
    func buildArrayOfNodes(){
        var set = Set<Nodes>()
        
        for var theRow = 0; theRow < dim; ++theRow{
            for var column = 0; column < dim; ++column{
                let node = Nodes(column: column, row: theRow, theNodeType: NodeType.Empty)
                
                node.nodeType = NodeType.Dot
                node.sprite = SKSpriteNode(imageNamed: "o")
                node.sprite?.name = "Dot"
                grid[column, theRow] = node
                set.insert(node)
                
            }
        }
        paintDots(set)
    }
    
    func paintDots(nodes: Set<Nodes>){
        for node in nodes{
            
            if node.sprite != nil{
                let position = pointForColumn(node.nodePos.column!, row: node.nodePos.row!, size: (node.sprite?.frame.size.width)!)
                let sprite = node.sprite
                sprite?.color = SKColor.redColor()
                sprite?.position = position
                if dim > 11{
                    sprite?.size = CGSizeMake(xIsopin!/1.3, yIsopin!/1.3)
                }else{
                    sprite?.size = CGSizeMake(xIsopin!/1.5, yIsopin!/1.5)
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
    
}