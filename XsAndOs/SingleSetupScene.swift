//
//  SingleSetupScene.swift
//  XsAndOs
//
//  Created by Derik Flanary on 2/10/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation
import SpriteKit

class SingleSetupScene: XandOScene, UITextFieldDelegate {
    
    //MARK: - PROPERTIES
    private let startButton = UIButton()
    private let sizeField = UITextField()
    private var stackView = UIStackView()
    private let xButton = CircleView()
    private let oButton = CircleView()
    private let rowsLabel = InfoLabel(frame: CGRectZero)
    private let teamLabel = InfoLabel(frame: CGRectZero)
    var userTeam = Board.UserTeam.X
    
    //MARK: - VIEW SETUP
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        layoutViews()
    }
    
    private func layoutViews(){
        startButton.frame = CGRectMake(20, (self.view?.center.y)! - 80, (self.view?.bounds.size.width)! - 40, 50)
        startButton.center.x = (self.view?.center.x)!
        startButton.setTitle("Start", forState: .Normal)
        startButton.titleLabel?.font = UIFont(name: boldFontName, size: 36)
        startButton.setTitleColor(textColor, forState: .Normal)
        startButton.setTitleColor(UIColor(white: 0.2, alpha: 0.6), forState: .Highlighted)
        startButton.addTarget(self, action: "newGamePressed", forControlEvents: .TouchUpInside)
        startButton.layer.cornerRadius = 25
        startButton.clipsToBounds = true
        startButton.backgroundColor = xColor
        
        sizeField.frame = CGRectMake(0, 0, 50, 50)
        sizeField.backgroundColor = textColor
        sizeField.textColor = thirdColor
        sizeField.font = UIFont(name: boldFontName, size: 50)
        sizeField.placeholder = "7"
        sizeField.keyboardType = UIKeyboardType.NumberPad
        sizeField.textAlignment = .Center
        sizeField.borderStyle = .RoundedRect
        sizeField.layer.cornerRadius = 50
        sizeField.clipsToBounds = true
        sizeField.delegate = self

        xButton.setImage(UIImage(named: "ex"), forState: .Normal)
        xButton.backgroundColor = xColor
        xButton.imageView?.contentMode = .Center
        xButton.layer.cornerRadius = 40
        xButton.clipsToBounds = true
        xButton.addTarget(self, action: "xPressed", forControlEvents: .TouchUpInside)
        
        oButton.setImage(UIImage(named: "oh"), forState: .Normal)
        oButton.backgroundColor = flint
        oButton.imageView?.contentMode = .Center
        oButton.layer.cornerRadius = 40
        oButton.clipsToBounds = true
        oButton.addTarget(self, action: "oPressed", forControlEvents: .TouchUpInside)
        
        
        rowsLabel.text = "Rows"
        teamLabel.text = "Team"
        
        addAutoContraints()
    }
    
    private func addAutoContraints(){
        let margins = self.view?.layoutMarginsGuide

        let innerStack = UIStackView(arrangedSubviews: [xButton, oButton])
        innerStack.axis = .Horizontal
        innerStack.alignment = .Center
        innerStack.distribution = .FillEqually
        innerStack.spacing = 50
        
        stackView = UIStackView(arrangedSubviews: [startButton, rowsLabel, sizeField, teamLabel, innerStack])
        stackView.axis = .Vertical
        stackView.alignment = .Center
        stackView.spacing = 21
        stackView.distribution = .EqualSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.view?.addSubview(stackView)
        
        stackView.leadingAnchor.constraintEqualToAnchor(margins?.leadingAnchor).active = true
        stackView.trailingAnchor.constraintEqualToAnchor(margins?.trailingAnchor).active = true
        stackView.centerXAnchor.constraintEqualToAnchor(margins?.centerXAnchor).active = true
        stackView.centerYAnchor.constraintEqualToAnchor(margins?.centerYAnchor, constant: -80).active = true
        stackView.heightAnchor.constraintEqualToConstant(350).active = true
        
        startButton.heightAnchor.constraintEqualToConstant(50).active = true
        startButton.widthAnchor.constraintGreaterThanOrEqualToAnchor(stackView.widthAnchor).active = true
        sizeField.widthAnchor.constraintEqualToConstant(100).active = true
        sizeField.heightAnchor.constraintEqualToConstant(100).active = true
        xButton.widthAnchor.constraintEqualToConstant(80).active = true
        xButton.heightAnchor.constraintEqualToConstant(80).active = true
        oButton.widthAnchor.constraintEqualToConstant(80).active = true
        oButton.heightAnchor.constraintEqualToConstant(80).active = true
    
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view?.endEditing(true)

    }
    
    //MARK: - BUTTON METHODS
    func xPressed(){
        oButton.backgroundColor = flint
        xButton.backgroundColor = xColor
        userTeam = .X
    }
    
    func oPressed(){
        xButton.backgroundColor = flint
        oButton.backgroundColor = oColor
        userTeam = .O
    }
    
    func newGamePressed(){
        var dim : Int
        var rows = Int(sizeField.text!)
        if rows == nil{
            dim = 13
            rows = 7
        }else{
            dim = BoardSetupController().calculateDim(rows!)
        }
        transitionToBoardScene(dim, rows: rows!)
        stackView.removeFromSuperview()
    }

    
    //MARK: - TRANSITIONS
    private func transitionToBoardScene(dim : Int, rows : Int){
        let secondScene = Board(size: self.view!.frame.size, theDim: dim, theRows: rows, userTeam: userTeam, aiGame: true)
        secondScene.scaleMode = SKSceneScaleMode.AspectFill
        self.scene!.view?.presentScene(secondScene, transition: transition)
    }

    
    //MARK: - TEXTFIELD DELEGATE
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.utf16.count + string.utf16.count - range.length
        return newLength <= 1 // Bool
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        guard let text = textField.text else { return }
        let textInt = Int(text)
        if textInt < 5{
            textField.text = "4"
        }else if textInt > 8{
            textField.text = "8"
        }
    }
}

class InfoLabel: UILabel{
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.numberOfLines = 0
        self.font = UIFont(name: mainFontName, size: 18)
        self.textColor = UIColor(red: 0.78, green: 0.81, blue: 0.83, alpha: 1.0)
        self.textAlignment = .Center
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}