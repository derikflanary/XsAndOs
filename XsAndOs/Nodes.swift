//
//  Nodes.swift
//  XsAndOs
//
//  Created by Derik Flanary on 11/9/15.
//  Copyright © 2015 Derik Flanary. All rights reserved.
//

import Foundation

import SpriteKit

enum NodeType: Int {
    case Unknown = 0, Empty, Intersection, X, O, Dot
}

struct Point
{
    var column : Int? 	// this is the array element  multiply it by  YIsopin + Dim * 11/3 and it will be the screen position.
    var row : Int?
    var ptClr : SKColor
    var ptWho : String?
    
}

class Nodes: Hashable  {
    
    var nodePos = Point(column: 0, row: 0, ptClr: SKColor.redColor(), ptWho: "")
    var nodeType : NodeType
    var sprite :SKSpriteNode?
    
    init(column: Int, row: Int, theNodeType: NodeType) {
        
        self.nodePos.column = column
        self.nodePos.row = row
        self.nodeType = theNodeType
    }

    var hashValue: Int {
        return nodePos.row!*10 + nodePos.column!
    }
}

func ==(lhs: Nodes, rhs: Nodes) -> Bool {
    return lhs.nodePos.column == rhs.nodePos.column && lhs.nodePos.row == rhs.nodePos.row
}