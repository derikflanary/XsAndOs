//
//  LineShapeLayer.swift
//  XsAndOs
//
//  Created by Derik Flanary on 1/14/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation


struct Coord {
    var columnA : Int
    var rowA : Int
    var columnB : Int
    var rowB : Int
}

class LineShapeLayer : CAShapeLayer {
    
    var team : String?
    var coordinates = [Coordinate]()
    var linesForParse : [[String: Int]]
    
    init(columnA: Int, rowA: Int, columnB: Int, rowB: Int, team: String) {
        linesForParse = []
        super.init()
        setupValues(columnA, rowA: rowA, columnB: columnB, rowB: rowB, team: team)
    }
    
    init(columnA: Int, rowA: Int, columnB: Int, rowB: Int, team: String, path: CGPathRef, color: CGColor) {
        linesForParse = []
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
    
    func addCoordinate(columnA: Int, rowA: Int, columnB: Int, rowB: Int){
        let coordinate = Coordinate(columnA: columnA, rowA: rowA, columnB: columnB, rowB: rowB)
        coordinates.append(coordinate)
    }
    
    func addCoordinatesFromLine(lineShapeNode: LineShapeNode){
        for coordinate in lineShapeNode.coordinates{
            self.addCoordinate(coordinate.columnA, rowA: coordinate.rowA, columnB: coordinate.columnB, rowB: coordinate.rowB)
        }
    }
    
    func setShapeAspects(newPath: CGPathRef){
        path = newPath
        name = "line"
        lineWidth = 4
        zPosition = 0
//        userInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func convertLinesForParse(){
        
        for coordinate in coordinates{
            let lineDict = coordinateToDict(coordinate)
            linesForParse.append(lineDict)
        }
    }
    
    func coordinateToDict(coordinate: Coordinate) -> [String: Int]{
        let dict = ["c": coordinate.columnA,
            "r": coordinate.rowA,
            "k": coordinate.columnB,
            "w": coordinate.rowB]
        return dict
    }



}