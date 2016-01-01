//
//  GCStackView.swift
//  XsAndOs
//
//  Created by Derik Flanary on 1/1/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation

class GCStackView: UIStackView {
    
    let startButton = UIButton()
    let sizeField = UITextField()
    let label = UILabel()
    let fbLoginbutton = UIButton()
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        
        startButton.frame = CGRectZero
        startButton.setTitle("Start Game", forState: .Normal)
        startButton.titleLabel?.font = UIFont.boldSystemFontOfSize(18)
        startButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        startButton.setTitleColor(UIColor(white: 0.2, alpha: 0.6), forState: .Highlighted)
        startButton.addTarget(self, action: "newGamePressed", forControlEvents: .TouchUpInside)
        
        label.frame = CGRectZero
        label.numberOfLines = 0
        label.text = "Choose the number of Rows and Columns (Min:4 | Max:8)"
        label.textAlignment = .Center
        
        sizeField.frame = CGRectZero
        sizeField.placeholder = "5"
        sizeField.keyboardType = UIKeyboardType.NumberPad
        sizeField.textAlignment = .Center
        sizeField.borderStyle = .RoundedRect
//        sizeField.delegate = self
        
        fbLoginbutton.frame = CGRectZero
        fbLoginbutton.setTitle("Log in with Facebook", forState: .Normal)
        fbLoginbutton.titleLabel?.font = UIFont.boldSystemFontOfSize(14)
        fbLoginbutton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        fbLoginbutton.setTitleColor(UIColor(white: 0.2, alpha: 0.6), forState: .Highlighted)
        fbLoginbutton.addTarget(self, action: "fbLoginPressed", forControlEvents: .TouchUpInside)
        
//        stackView = UIStackView(arrangedSubviews: [startButton, label, sizeField, fbLoginbutton])
        self.addArrangedSubview(startButton)
        self.addArrangedSubview(label)
        self.addArrangedSubview(sizeField)
        self.addArrangedSubview(fbLoginbutton)
        
        self.axis = .Vertical
        self.spacing = 20
        self.distribution = .FillEqually

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}