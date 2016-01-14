//
//  LineShapeLayer.swift
//  XsAndOs
//
//  Created by Derik Flanary on 1/14/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation


struct Coordinate {
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
    
    func addCoordinatesFromLine(lineShapeLayer: LineShapeLayer){
        for coordinate in lineShapeLayer.coordinates{
            self.addCoordinate(coordinate.columnA, rowA: coordinate.rowA, columnB: coordinate.columnB, rowB: coordinate.rowB)
        }
    }
    
    func setShapeAspects(newPath: CGPathRef){
        path = newPath
        lineJoin = kCALineJoinRound
        lineCap = kCALineCapRound
        name = "line"
        fillColor = nil
        strokeEnd = 1.0
        lineWidth = 4
        zPosition = 0
//        userInteractionEnabled = false
    }
    
    func createPath(pointA pointA: CGPoint, pointB: CGPoint) -> CGPathRef{
        let newPath = UIBezierPath()
        newPath.moveToPoint(pointA)
        newPath.addLineToPoint(pointB)
        return newPath.CGPath
    }
    
    func appendPath(newPath: CGPathRef){
        if path != nil{
            let bez = UIBezierPath(CGPath: path!)
            let bez2 = UIBezierPath(CGPath: newPath)
            bez.appendPath(bez2)
            path = bez.CGPath
        }
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
    
    func copyLineValues(lineShapeLayer: LineShapeLayer){
        team = lineShapeLayer.team
        coordinates = lineShapeLayer.coordinates
        setShapeAspects(lineShapeLayer.path!)
        strokeColor = lineShapeLayer.strokeColor
    }
    

}