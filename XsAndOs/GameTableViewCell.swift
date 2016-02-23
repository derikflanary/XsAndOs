//
//  GameTableViewCell.swift
//  XsAndOs
//
//  Created by Derik Flanary on 2/18/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation

class GameTableViewCell: UITableViewCell {
    
    let xLabel = UILabel()
    let oLabel = UILabel()
    let dateLabel = UILabel()
    let sizeLabel = UILabel()
    let shadowView = UIView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        xLabel.textColor = xColor
        xLabel.font = UIFont(name: boldFontName, size: 24)
        xLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(xLabel)
        
        oLabel.textColor = oColor
        oLabel.font = UIFont(name: boldFontName, size: 24)
        oLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(oLabel)
        
        dateLabel.textColor = flint
        dateLabel.font = UIFont(name: lightFontName, size: 16)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dateLabel)
        
        sizeLabel.textColor = flint
        sizeLabel.font = UIFont(name: lightFontName, size: 16)
        sizeLabel.textAlignment = .Right
        sizeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(sizeLabel)
        
        let margins = self.layoutMarginsGuide
        xLabel.leadingAnchor.constraintEqualToAnchor(margins.leadingAnchor).active = true
        xLabel.trailingAnchor.constraintEqualToAnchor(margins.trailingAnchor).active = true
        xLabel.heightAnchor.constraintEqualToConstant(25).active = true
        xLabel.topAnchor.constraintEqualToAnchor(margins.topAnchor, constant: 5).active = true
        
        oLabel.leadingAnchor.constraintEqualToAnchor(margins.leadingAnchor).active = true
        oLabel.trailingAnchor.constraintEqualToAnchor(margins.trailingAnchor).active = true
        oLabel.heightAnchor.constraintEqualToConstant(25).active = true
        oLabel.topAnchor.constraintEqualToAnchor(xLabel.bottomAnchor, constant: 10).active = true
        
        dateLabel.leadingAnchor.constraintEqualToAnchor(margins.leadingAnchor).active = true
        dateLabel.widthAnchor.constraintEqualToConstant(200).active = true
        dateLabel.heightAnchor.constraintEqualToConstant(20).active = true
        dateLabel.topAnchor.constraintEqualToAnchor(oLabel.bottomAnchor, constant: 0).active = true
        
        sizeLabel.trailingAnchor.constraintEqualToAnchor(margins.trailingAnchor).active = true
        sizeLabel.widthAnchor.constraintEqualToConstant(40).active = true
        sizeLabel.heightAnchor.constraintEqualToConstant(20).active = true
        sizeLabel.topAnchor.constraintEqualToAnchor(dateLabel.topAnchor, constant: 0).active = true
    
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        animateTurnView()
    }
    
    func addTurnLabel(){
        
        let turnView = UIView(frame: CGRectMake(300, 25, 50, 50))
        turnView.backgroundColor = xColor
        turnView.layer.cornerRadius = 25.0
        turnView.clipsToBounds = true
        turnView.translatesAutoresizingMaskIntoConstraints = false
        
        let turnLabel = UILabel(frame: turnView.bounds)
        turnLabel.textAlignment = .Center
        turnLabel.text = "YOUR TURN"
        turnLabel.font = UIFont(name: boldFontName, size: 8)
        turnLabel.textColor = UIColor.whiteColor()

        contentView.addSubview(turnView)
        turnView.addSubview(turnLabel)
        
        let margins = self.layoutMarginsGuide
        turnView.trailingAnchor.constraintEqualToAnchor(sizeLabel.trailingAnchor).active = true
        turnView.widthAnchor.constraintEqualToConstant(50).active = true
        turnView.heightAnchor.constraintEqualToConstant(50).active = true
        turnView.bottomAnchor.constraintEqualToAnchor(margins.bottomAnchor, constant: -20).active = true

    }
    
    func animateTurnView(){
        UIView.animateWithDuration(1.0, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 20, options: .CurveEaseOut, animations: { () -> Void in
            self.shadowView.frame = CGRectMake(300, 25, 50, 50)
            self.layoutIfNeeded()
            }) { (done) -> Void in
                
            }
    }
}


