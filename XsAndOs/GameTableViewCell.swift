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
        sizeLabel.textAlignment = .right
        sizeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(sizeLabel)
        
        let margins = self.layoutMarginsGuide
        xLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        xLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        xLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
        xLabel.topAnchor.constraint(equalTo: margins.topAnchor, constant: 5).isActive = true
        
        oLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        oLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        oLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
        oLabel.topAnchor.constraint(equalTo: xLabel.bottomAnchor, constant: 10).isActive = true
        
        dateLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
        dateLabel.widthAnchor.constraint(equalToConstant: 200).isActive = true
        dateLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        dateLabel.topAnchor.constraint(equalTo: oLabel.bottomAnchor, constant: 0).isActive = true
        
        sizeLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        sizeLabel.widthAnchor.constraint(equalToConstant: 40).isActive = true
        sizeLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        sizeLabel.topAnchor.constraint(equalTo: dateLabel.topAnchor, constant: 0).isActive = true
    
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        animateTurnView()
    }
    
    func addTurnLabel(){
        
        let turnView = UIView(frame: CGRect(x: 300, y: 25, width: 50, height: 50))
        turnView.backgroundColor = xColor
        turnView.layer.cornerRadius = 25.0
        turnView.clipsToBounds = true
        turnView.translatesAutoresizingMaskIntoConstraints = false
        
        let turnLabel = UILabel(frame: turnView.bounds)
        turnLabel.textAlignment = .center
        turnLabel.text = "YOUR TURN"
        turnLabel.font = UIFont(name: boldFontName, size: 8)
        turnLabel.textColor = UIColor.white

        contentView.addSubview(turnView)
        turnView.addSubview(turnLabel)
        
        let margins = self.layoutMarginsGuide
        turnView.trailingAnchor.constraint(equalTo: sizeLabel.trailingAnchor).isActive = true
        turnView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        turnView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        turnView.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -20).isActive = true

    }
    
    func animateTurnView(){
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 20, options: .curveEaseOut, animations: { () -> Void in
            self.shadowView.frame = CGRect(x: 300, y: 25, width: 50, height: 50)
            self.layoutIfNeeded()
            }) { (done) -> Void in
                
            }
    }
}


