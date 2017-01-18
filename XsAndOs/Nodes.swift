//
//  Nodes.swift
//  XsAndOs
//
//  Created by Derik Flanary on 11/9/15.
//  Copyright © 2015 Derik Flanary. All rights reserved.
//

import Foundation

import SpriteKit

enum NodeType {
    case unknown, empty, intersection, x, o, dot
}

struct Point
{
    var column : Int?
    var row : Int?
    var ptClr : SKColor
    var ptWho : String?
    
}

class Node: Hashable  {
    
    var nodePos = Point(column: 0, row: 0, ptClr: SKColor.red, ptWho: "")
    var nodeType : NodeType
    var sprite : SKSpriteNode?
    var position : CGPoint?
    
    init(column: Int, row: Int, theNodeType: NodeType) {
        self.nodePos.column = column
        self.nodePos.row = row
        self.nodeType = theNodeType
    }

    var hashValue: Int {
        return nodePos.row!*10 + nodePos.column!
    }
}

func ==(lhs: Node, rhs: Node) -> Bool {
    return lhs.nodePos.column == rhs.nodePos.column && lhs.nodePos.row == rhs.nodePos.row
}
