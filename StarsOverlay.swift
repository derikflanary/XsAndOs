//
//  StarsOverlay.swift
//  StarWarsAnimations
//
//  Created by Artem Sidorenko on 9/11/15.
//  Copyright © 2015 Yalantis. All rights reserved.
//

import UIKit

class StarsOverlay: UIView {

    override class func layerClass() -> AnyClass {
        return CAEmitterLayer.self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    private var emitter: CAEmitterLayer {
        return layer as! CAEmitterLayer
    }
    
    private var particle: CAEmitterCell!
    private var oparticle: CAEmitterCell!
    
    func setup() {
        emitter.emitterMode = kCAEmitterLayerOutline
        emitter.emitterShape = kCAEmitterLayerCircle
        emitter.renderMode = kCAEmitterLayerOldestFirst
        emitter.preservesDepth = true
        
        particle = CAEmitterCell()
        
        particle.contents = UIImage(named: "x")!.CGImage
        particle.birthRate = 1.0
        
        particle.lifetime = 20
        particle.lifetimeRange = 5
        
        particle.velocity = 60
        particle.velocityRange = 10
        particle.spin = 0.5
        
        particle.scale = 1.0
        particle.scaleRange = 0.5
        particle.scaleSpeed = 0.04
        
        oparticle = CAEmitterCell()
        
        oparticle.contents = UIImage(named: "o")!.CGImage
        oparticle.birthRate = 0.5
        
        oparticle.lifetime = 60
        oparticle.lifetimeRange = 5
        
        oparticle.velocity = 20
        oparticle.velocityRange = 10
        oparticle.spin = 0.5
        
        oparticle.scale = 0.5
        oparticle.scaleRange = 0.5
        oparticle.scaleSpeed = 0.04
        
        emitter.emitterCells = [particle, oparticle]
    }
    
    var emitterTimer: NSTimer?
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        if self.window != nil {
            if emitterTimer == nil {
                emitterTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "randomizeEmitterPosition", userInfo: nil, repeats: true)
            }
        } else if emitterTimer != nil {
            emitterTimer?.invalidate()
            emitterTimer = nil
        }
    }
    
    func randomizeEmitterPosition() {
        let sizeWidth = max(bounds.width, bounds.height)
        let radius = CGFloat(arc4random()) % sizeWidth
//        emitter.emitterSize = CGSize(width: radius, height: radius)
//        particle.birthRate = 10 + sqrt(Float(radius))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        emitter.emitterPosition = CGPointMake(-50, self.frame.size.height/2)
        emitter.emitterSize = CGSizeMake(10, 10)
    }
}
