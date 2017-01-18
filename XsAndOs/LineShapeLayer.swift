//
//  LineShapeLayer.swift
//  XsAndOs
//
//  Created by Derik Flanary on 1/14/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation

class LineShapeLayer : CAShapeLayer {
    
    var team : String?
    var coordinates = [Coordinate]()
    var linesForParse : [[String: Int]]
    
    init(columnA: Int, rowA: Int, columnB: Int, rowB: Int, team: String) {
        linesForParse = []
        super.init()
        setupValues(columnA, rowA: rowA, columnB: columnB, rowB: rowB, team: team)
    }
    
    init(columnA: Int, rowA: Int, columnB: Int, rowB: Int, team: String, path: CGPath, color: CGColor) {
        linesForParse = []
        super.init()
        setupValues(columnA, rowA: rowA, columnB: columnB, rowB: rowB, team: team)
        setShapeAspects(path)
        strokeColor = color
    }

    fileprivate func setupValues(_ columnA: Int, rowA: Int, columnB: Int, rowB: Int, team: String){
        let coordinate = Coordinate(columnA: columnA, rowA: rowA, columnB: columnB, rowB: rowB, position: nil)
        coordinates.append(coordinate)
        self.team = team
    }
    
    func addCoordinate(_ columnA: Int, rowA: Int, columnB: Int, rowB: Int){
        let coordinate = Coordinate(columnA: columnA, rowA: rowA, columnB: columnB, rowB: rowB, position: nil)
        coordinates.append(coordinate)
    }
    
    func addCoordinatesFromLine(_ lineShapeLayer: LineShapeLayer){
        for coordinate in lineShapeLayer.coordinates{
            self.addCoordinate(coordinate.columnA, rowA: coordinate.rowA, columnB: coordinate.columnB, rowB: coordinate.rowB)
        }
    }
    
    func setShapeAspects(_ newPath: CGPath){
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
    
    func createPath(pointA: CGPoint, pointB: CGPoint) -> CGPath{
        let newPath = UIBezierPath()
        newPath.move(to: pointA)
        newPath.addLine(to: pointB)
        return newPath.cgPath
    }
    
    func appendPath(_ newPath: CGPath){
        if path != nil{
            let bez = UIBezierPath(cgPath: path!)
            let bez2 = UIBezierPath(cgPath: newPath)
            bez.append(bez2)
            path = bez.cgPath
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
    
    func coordinateToDict(_ coordinate: Coordinate) -> [String: Int]{
        let dict = ["c": coordinate.columnA,
            "r": coordinate.rowA,
            "k": coordinate.columnB,
            "w": coordinate.rowB]
        return dict
    }
    
    func copyLineValues(_ lineShapeLayer: LineShapeLayer){
        team = lineShapeLayer.team
        coordinates = lineShapeLayer.coordinates
        setShapeAspects(lineShapeLayer.path!)
        strokeColor = lineShapeLayer.strokeColor
    }
    

}

extension LineShapeLayer: CAAnimationDelegate {
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag{
            self.removeFromSuperlayer()
        }
    }
    
}

