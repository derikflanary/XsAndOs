//
//  Button.swift
//  XsAndOs
//
//  Created by Derik Flanary on 2/10/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation

class Button: UIButton {
    
    var shadowLayer: CAShapeLayer!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel?.font = UIFont(name: boldFontName, size: 36)
        setTitleColor(UIColor(white: 0.95, alpha: 1.0), forState: .Normal)
        setTitleColor(UIColor(white: 0.2, alpha: 0.6), forState: .Highlighted)
        layer.cornerRadius = 25
        clipsToBounds = true

    }
    
    override var highlighted: Bool {
        get {
            return super.highlighted
        }
        set {
            if newValue {
                alpha = 0.9
            }
            else {
                alpha = 1.0
            }
            super.highlighted = newValue
        }
    }

    
}
