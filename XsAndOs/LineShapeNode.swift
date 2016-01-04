//
//  LineShapeNode.swift
//  XsAndOs
//
//  Created by Derik Flanary on 12/10/15.
//  Copyright © 2015 Derik Flanary. All rights reserved.
//

import Foundation
import SpriteKit

struct Coordinate {
    var columnA : Int?
    var rowA : Int?
    var columnB : Int?
    var rowB : Int?
}

class LineShapeNode: SKShapeNode {
    
    var team : String?
    var coordinates = [Coordinate]()
    
    init(columnA: Int, rowA: Int, columnB: Int, rowB: Int, team: String) {
        super.init()
        setupValues(columnA, rowA: rowA, columnB: columnB, rowB: rowB, team: team)
        
        
    }
    
    init(columnA: Int, rowA: Int, columnB: Int, rowB: Int, team: String, path: CGPathRef, color: SKColor) {
        super.init()
        setupValues(columnA, rowA: rowA, columnB: columnB, rowB: rowB, team: team)
        setShapeAspects(path)
        strokeColor = color
    }
    
    private func setupValues(columnA: Int, rowA: Int, columnB: Int, rowB: Int, team: String){
        let coordinate = Coordinate(columnA: columnA, rowA: rowA, columnB: columnB, rowB: rowB)
        coordinates.append(coordinate)
        self.team = team
    }
    
    func appendPath(newPath: CGPathRef){
        let originalPath = self.path as! CGMutablePathRef
        CGPathAddPath(originalPath, nil, newPath)
        self.path = originalPath

    }
    
    func addCoordinate(columnA: Int, rowA: Int, columnB: Int, rowB: Int){
        let coordinate = Coordinate(columnA: columnA, rowA: rowA, columnB: columnB, rowB: rowB)
        coordinates.append(coordinate)
    }
    
    func addCoordinatesFromLine(lineShapeNode: LineShapeNode){
        for coordinate in lineShapeNode.coordinates{
            self.addCoordinate(coordinate.columnA!, rowA: coordinate.rowA!, columnB: coordinate.columnB!, rowB: coordinate.rowB!)
        }
    }
    
    func setShapeAspects(newPath: CGPathRef){
        path = newPath
        name = "line"
        lineWidth = 4
        zPosition = 0
        userInteractionEnabled = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}