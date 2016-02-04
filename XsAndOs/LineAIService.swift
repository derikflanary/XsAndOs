//
//  LineAIService.swift
//  XsAndOs
//
//  Created by Derik Flanary on 2/4/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation

class LineAIService {
    
    var grid : Array2D<Node>
    
    //MARK: - INIT
    init(grid: Array2D<Node>){
        self.grid = grid
    }

    
    func calculateAIMove() -> (Coordinate?, Node?) {
        let lineAI = LineAI(grid: grid)
        return lineAI.calculateAIMove()
    }
}