//
//  ShortPath.swift
//  XsAndOs
//
//  Created by Derik Flanary on 2/3/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation

struct ShortPath {
    var steps = [ShortestPathStep]()
    var fScore : Int {
        if steps.count > 0{
            return (steps.last?.fScore)!
        }else{
            return 100
        }
    }
    
    init(steps: [ShortestPathStep]){
        self.steps = steps
    }
    
}