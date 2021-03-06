//
//  Array2D.swift
//  XsAndOs
//
//  Created by Derik Flanary on 11/9/15.
//  Copyright © 2015 Derik Flanary. All rights reserved.
//

import Foundation

struct Array2D<T> {
    let columns: Int
    let rows: Int
    fileprivate var array: Array<T?>
    
    init(columns: Int, rows: Int) {
        self.columns = columns
        self.rows = rows
        array = Array<T?>(repeating: nil, count: rows*columns)
    }
    
    subscript(column: Int, row: Int) -> T? {
        get {
            return array[row * columns + column]
        }
        set {
            array[row * columns + column] = newValue
        }
    }
    
    mutating func removeArray(){
        array.removeAll()
    }
}
