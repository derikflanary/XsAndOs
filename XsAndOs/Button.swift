//
//  Button.swift
//  XsAndOs
//
//  Created by Derik Flanary on 2/10/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation

class Button: UIButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setTitleColor(UIColor(white: 0.95, alpha: 1.0), forState: .Normal)
        setTitleColor(UIColor(white: 0.95, alpha: 1.0), forState: .Highlighted)
        layer.cornerRadius = self.frame.size.height/2
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
                alpha = 1
            }
            super.highlighted = newValue
        }
    }

}


class SButton: UIButton {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setTitleColor(UIColor(white: 0.95, alpha: 1.0), forState: .Normal)
        setTitleColor(UIColor(white: 0.95, alpha: 1.0), forState: .Highlighted)
        layer.cornerRadius = self.frame.size.height/2
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
                
            }
            super.highlighted = newValue
        }
    }
    
}
