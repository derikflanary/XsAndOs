//
//  AStarCalculator.swift
//  XsAndOs
//
//  Created by Derik Flanary on 1/27/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation

struct Location {
    var column : Int
    var row : Int
}

class ShortestPathStep{
    
    // MARK: - Properties
    let point : CGPoint?
    let location : Location
    var hScore : Int = 0
    var gScore : Int = 0
    var fScore : Int{
        return hScore + gScore
    }
    var description: String {
        return "col:\(location.column), row:\(location.row), g:\(gScore), h:\(hScore), f:\(fScore)"
    }
    var parent : ShortestPathStep?
    var cost : Int = 2
    // MARK: - Initialization
    
    init(node: Node){
        self.point = node.position
        self.location = Location(column: node.nodePos.column!, row: node.nodePos.row!)
        self.parent = nil
    }
    
}

extension ShortestPathStep: Equatable {}

func ==(lhs: ShortestPathStep, rhs: ShortestPathStep) -> Bool {
    return lhs.location.column == rhs.location.column && lhs.location.row == rhs.location.row
}