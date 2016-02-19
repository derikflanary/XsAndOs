//
//  GameTableViewCell.swift
//  XsAndOs
//
//  Created by Derik Flanary on 2/18/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation

class GameTableViewCell: UITableViewCell {
    
    override func layoutSubviews() {
        self.layer.cornerRadius = 15
        self.clipsToBounds = true
    }
}
