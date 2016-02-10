//
//  CircleButton.swift
//  XsAndOs
//
//  Created by Derik Flanary on 2/9/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation

class CircleView: UIButton{
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = frame.width/2
        self.clipsToBounds = true
        self.backgroundColor = oColor
        self.titleLabel?.font = UIFont(name: boldFontName, size: 24)
        self.setTitleColor(textColor, forState: .Normal)
        self.setTitleColor(UIColor(white: 0.2, alpha: 0.6), forState: .Highlighted)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

