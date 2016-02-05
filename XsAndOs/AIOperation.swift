//
//  AIOperation.swift
//  XsAndOs
//
//  Created by Derik Flanary on 2/5/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation


class AIMoveCalculator: NSOperation {
    
    private let lineAI: LineAI
    var node : Node?
    var coordinate : Coordinate?
    
    //MARK: - INIT
    init(grid: Array2D<Node>){
        lineAI = LineAI(grid: grid, difficulty: .Moderate)
    }
    
        //3
    override func main() {
        //4
        guard !self.cancelled else {return}
        let (coord, node) = lineAI.calculateAIMove()
        self.node = node
        self.coordinate = coord
        
    }
}