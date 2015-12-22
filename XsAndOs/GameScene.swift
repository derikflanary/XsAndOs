//
//  GameScene.swift
//  XsAndOs
//
//  Created by Derik Flanary on 10/26/15.
//  Copyright (c) 2015 Derik Flanary. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    let startButton = UIButton()
    let sizeField = UITextField()
    let label = UILabel()
    var stackView = UIStackView()
    
    override func didMoveToView(view: SKView) {
        
        
        startButton.frame = CGRectMake(0, 100, (self.view?.frame.size.width)!, 50)
        startButton.setTitle("Start Game", forState: .Normal)
        startButton.titleLabel?.font = UIFont.boldSystemFontOfSize(18)
        startButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        startButton.setTitleColor(UIColor(white: 0.2, alpha: 0.6), forState: .Highlighted)
        startButton.addTarget(self, action: "newGamePressed", forControlEvents: .TouchUpInside)
        
        label.frame = CGRectMake(0, 150, self.view!.frame.size.width, 40)
        label.numberOfLines = 0
        label.text = "Choose the number of Rows and Columns (Min:5 Max 8)"
        label.textAlignment = .Center
        
        sizeField.frame = CGRectZero
        sizeField.placeholder = "5"
        sizeField.keyboardType = UIKeyboardType.NumberPad
        sizeField.textAlignment = .Center
        sizeField.borderStyle = .RoundedRect
        
        stackView = UIStackView(arrangedSubviews: [startButton, label, sizeField])
        stackView.axis = .Vertical
        stackView.spacing = 20
        stackView.distribution = .FillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.view?.addSubview(stackView)
        
        let margins = self.view?.layoutMarginsGuide
        stackView.leadingAnchor.constraintEqualToAnchor(margins?.leadingAnchor).active = true
        stackView.trailingAnchor.constraintEqualToAnchor(margins?.trailingAnchor).active = true
        stackView.centerXAnchor.constraintEqualToAnchor(margins?.centerXAnchor).active = true
        stackView.centerYAnchor.constraintEqualToAnchor(margins?.centerYAnchor, constant: -80).active = true
        stackView.heightAnchor.constraintEqualToConstant(200).active = true
        
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        self.backgroundColor = SKColor.whiteColor()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
      
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func newGamePressed(){
        print("newGamePressed")

        let transition = SKTransition.crossFadeWithDuration(1)
        
        var dim = Int(sizeField.text!)
        if sizeField.text != nil{
            if dim < 5{
                dim = 5
            }else if dim == 6{
                dim = 7
            }else if dim == 7{
                dim = 9
            }else if dim >= 8{
                dim = 11
            }
            dim = dim! + 4
        }else{
            dim = 9
        }
        
        let secondScene = Board(size: self.size, theDim: dim!)
        secondScene.scaleMode = SKSceneScaleMode.AspectFill
        self.scene!.view?.presentScene(secondScene, transition: transition)
        
        stackView.removeFromSuperview()
    }
}
