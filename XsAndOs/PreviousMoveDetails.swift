//
//  PreviousMoveDetails.swift
//  XsAndOs
//
//  Created by Derik Flanary on 2/12/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation

struct PreviousMoveDetails {
    var oldLines = [LineShapeLayer]()
    var previousIntersection : LastIntersectionLocation
    var moveUnDid = false
    var newAppendedLine : LineShapeLayer
}