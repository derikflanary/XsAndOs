//
//  LineAnimationOperation.swift
//  XsAndOs
//
//  Created by Derik Flanary on 2/5/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation



class LineAnimationOperation: Operation {
    
    enum AnimationType{
        case normal
        case delete
    }
    fileprivate var type : AnimationType
    fileprivate var line : LineShapeLayer
    //MARK: - INIT
    init(line: LineShapeLayer, type: AnimationType){
        self.type = type
        self.line = line
    }
    
    //3
    override func main() {
        switch type{
        case .normal:
            animateWidth(line)
        case .delete:
            animateWidthThenDelete(line)
        }
    }
    
    func animateWidth(_ line: LineShapeLayer){
        let animation = CABasicAnimation(keyPath: "lineWidth")
        animation.toValue = 6
        animation.duration = 0.25
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut) // animation curve is Ease Out
        animation.autoreverses = true
        animation.fillMode = CAMediaTimingFillMode.both // keep to value after finishing
        animation.isRemovedOnCompletion = false // don't remove after finishing
        line.add(animation, forKey: animation.keyPath)
    }
    
    func animateWidthThenDelete(_ line: LineShapeLayer){
        let animation = CABasicAnimation(keyPath: "lineWidth")
        animation.toValue = 6
        animation.duration = 0.25
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut) // animation curve is Ease Out
        animation.autoreverses = true
        animation.delegate = line
        animation.fillMode = CAMediaTimingFillMode.both // keep to value after finishing
        animation.isRemovedOnCompletion = false // don't remove after finishing
        line.add(animation, forKey: animation.keyPath)
    }

}
