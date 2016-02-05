//
//  LineAnimationOperation.swift
//  XsAndOs
//
//  Created by Derik Flanary on 2/5/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation



class LineAnimationOperation: NSOperation {
    
    enum AnimationType{
        case Normal
        case Delete
    }
    private var type : AnimationType
    private var line : LineShapeLayer
    //MARK: - INIT
    init(line: LineShapeLayer, type: AnimationType){
        self.type = type
        self.line = line
    }
    
    //3
    override func main() {
        switch type{
        case .Normal:
            animateWidth(line)
        case .Delete:
            animateWidthThenDelete(line)
        }
    }
    
    func animateWidth(line: LineShapeLayer){
        let animation = CABasicAnimation(keyPath: "lineWidth")
        animation.toValue = 6
        animation.duration = 0.25
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut) // animation curve is Ease Out
        animation.autoreverses = true
        animation.fillMode = kCAFillModeBoth // keep to value after finishing
        animation.removedOnCompletion = false // don't remove after finishing
        line.addAnimation(animation, forKey: animation.keyPath)
    }
    
    func animateWidthThenDelete(line: LineShapeLayer){
        let animation = CABasicAnimation(keyPath: "lineWidth")
        animation.toValue = 6
        animation.duration = 0.25
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut) // animation curve is Ease Out
        animation.autoreverses = true
        animation.delegate = line
        animation.fillMode = kCAFillModeBoth // keep to value after finishing
        animation.removedOnCompletion = false // don't remove after finishing
        line.addAnimation(animation, forKey: animation.keyPath)
    }

}
