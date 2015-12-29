//
//  GameScene.swift
//  XsAndOs
//
//  Created by Derik Flanary on 10/26/15.
//  Copyright (c) 2015 Derik Flanary. All rights reserved.
//

import SpriteKit
import Parse
import ParseFacebookUtilsV4

class GameScene: SKScene, UITextFieldDelegate {
    
    let startButton = UIButton()
    let sizeField = UITextField()
    let label = UILabel()
    var stackView = UIStackView()
    let fbLoginbutton = UIButton()
    
    
    override func didMoveToView(view: SKView) {
        
        
        startButton.frame = CGRectMake(0, 100, (self.view?.frame.size.width)!, 50)
        startButton.setTitle("Start Game", forState: .Normal)
        startButton.titleLabel?.font = UIFont.boldSystemFontOfSize(18)
        startButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        startButton.setTitleColor(UIColor(white: 0.2, alpha: 0.6), forState: .Highlighted)
        startButton.addTarget(self, action: "newGamePressed", forControlEvents: .TouchUpInside)
        
        label.frame = CGRectMake(0, 150, self.view!.frame.size.width, 40)
        label.numberOfLines = 0
        label.text = "Choose the number of Rows and Columns (Min:4 | Max:8)"
        label.textAlignment = .Center
        
        sizeField.frame = CGRectZero
        sizeField.placeholder = "5"
        sizeField.keyboardType = UIKeyboardType.NumberPad
        sizeField.textAlignment = .Center
        sizeField.borderStyle = .RoundedRect
        sizeField.delegate = self
        
        
        fbLoginbutton.frame = CGRectMake(0, 100, (self.view?.frame.size.width)!, 50)
        fbLoginbutton.setTitle("Log in with Facebook", forState: .Normal)
        fbLoginbutton.titleLabel?.font = UIFont.boldSystemFontOfSize(14)
        fbLoginbutton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        fbLoginbutton.setTitleColor(UIColor(white: 0.2, alpha: 0.6), forState: .Highlighted)
        fbLoginbutton.addTarget(self, action: "fbLoginPressed", forControlEvents: .TouchUpInside)
        
        stackView = UIStackView(arrangedSubviews: [startButton, label, sizeField, fbLoginbutton])
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
        stackView.heightAnchor.constraintEqualToConstant(250).active = true
        
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
        var dim = 9
        var rows = Int(sizeField.text!)
        
        if rows != nil{
            if rows < 5{
                rows = 4
                dim = 3
            }else if rows == 5{
                dim = 5
            }else if rows == 6{
                dim = 7
            }else if rows == 7{
                dim = 9
            }else if rows >= 8{
                rows = 8
                dim = 11
            }
            dim = dim + 4
        }else{
            dim = 9
            rows = 5
        }
        
        let secondScene = Board(size: self.size, theDim: dim, theRows: rows!)
        secondScene.scaleMode = SKSceneScaleMode.AspectFill
        self.scene!.view?.presentScene(secondScene, transition: transition)
        
        stackView.removeFromSuperview()
    }
    
    func fbLoginPressed(){
        print("fbLoginPressed")
        
        FacebookController.Singleton.sharedInstance.loginToFacebook { (success) -> Void in
            if success{
                print("successful login")   
            }
        }
        
        
                
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        
        let newLength = text.utf16.count + string.utf16.count - range.length
        return newLength <= 1 // Bool
    }
}
