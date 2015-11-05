//
//  Node.swift
//  XsAndOs
//
//  Created by Derik Flanary on 11/5/15.
//  Copyright © 2015 Derik Flanary. All rights reserved.
//

import SpriteKit

struct Point
{
    var ptX : Int? 	// this is the array element  multiply it by  YIsopin + Dim * 11/3 and it will be the screen position.
    var ptY : Int?
    var ptClr : SKColor
    var ptWho : String?
    
}

class Node: SKNode {
    let nodePos = Point(ptX: 0, ptY: 0, ptClr: SKColor.redColor(), ptWho: "")
    var nodeType = ""
    
    
    
}


