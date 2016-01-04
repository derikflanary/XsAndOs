//
//  BoardSetupController.swift
//  XsAndOs
//
//  Created by Derik Flanary on 1/4/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation

class BoardSetupController: NSObject {
    
    func calculateDim(var rows : Int) -> Int{
        var dim = 9
        if rows < 5{
            rows = 4
            dim = 3
        }else if rows == 5{
            dim = 5
        }else if rows == 6{
            dim = 7
        }else if rows == 7{
            dim = 9
        }else if rows >= 8{
            rows = 8
            dim = 11
        }
        dim = dim + 4
        return dim
    }

}