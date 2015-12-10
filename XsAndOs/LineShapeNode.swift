//
//  LineShapeNode.swift
//  XsAndOs
//
//  Created by Derik Flanary on 12/10/15.
//  Copyright © 2015 Derik Flanary. All rights reserved.
//

import Foundation
import SpriteKit


class LineShapeNode: SKShapeNode {
    var columnA : Int?
    var rowA : Int?
    var columnB : Int?
    var rowB : Int?
    var team : String?
    
    init(columnA: Int, rowA: Int, columnB: Int, rowB: Int, team: String) {
        super.init()
        
        self.columnA = columnA
        self.rowA = rowA
        self.columnB = columnB
        self.rowB = rowB
        self.team = team
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}