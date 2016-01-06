//
//  MultiplayerSetupScene.swift
//  XsAndOs
//
//  Created by Derik Flanary on 1/4/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation
import SpriteKit
import Parse


class MultiplayerSetupScene: SKScene, UITextFieldDelegate {
    
    var opponent = PFUser()
    let startButton = UIButton()
    let sizeField = UITextField()
    let label = UILabel()
    var stackView = UIStackView()
    let oppLabel = UILabel()
    let backButton = UIButton()
    
    override func didMoveToView(view: SKView) {
        
        self.backgroundColor = SKColor.whiteColor()
        
        backButton.frame = CGRectMake(10, 20, 50, 30)
        backButton.setTitle("Main", forState: .Normal)
        backButton.setTitleColor(UIColor(white: 0.4, alpha: 1), forState: .Normal)
        backButton.setTitleColor(UIColor(white: 0.7, alpha: 1), forState: .Highlighted)
        backButton.addTarget(self, action: "mainPressed", forControlEvents: .TouchUpInside)
        backButton.tag = 20
        self.view?.addSubview(backButton)
        
        oppLabel.frame = CGRectMake(0, 150, self.view!.frame.size.width, 40)
        oppLabel.numberOfLines = 0
        let oppName = opponent["name"]
        oppLabel.text = "Opponent: \(oppName)"
        oppLabel.textAlignment = .Center
        
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
        
        stackView = UIStackView(arrangedSubviews: [oppLabel, startButton, label, sizeField])
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
    
    func newGamePressed(){
        print("new game pressed")
        var dim : Int
        var rows = Int(sizeField.text!)
        
        if rows == nil{
            dim = 9
            rows = 5
        }else{
            dim = BoardSetupController().calculateDim(rows!)
        }

        transitionToBoardScene(dim, rows: rows!)
        stackView.removeFromSuperview()
        backButton.removeFromSuperview()
    }
    
    private func transitionToBoardScene(dim : Int, rows : Int){
        let secondScene = MultiplayerBoard(size: self.view!.frame.size, theDim: dim, theRows: rows)
        secondScene.xUser = PFUser.currentUser()!
        secondScene.oUser = opponent
        secondScene.xTurnLoad = true
        secondScene.scaleMode = SKSceneScaleMode.AspectFill
        let transition = SKTransition.crossFadeWithDuration(1)
        XGameController.Singleton.sharedInstance.createNewGame(PFUser.currentUser()!, oTeam: opponent, rows: rows, dim: dim) { (success, id, xId, oId) -> Void in
            if success{
                secondScene.gameID = id
                secondScene.xObjId = xId
                secondScene.oObjId = oId
                self.scene!.view?.presentScene(secondScene, transition: transition)
            }
        }

    }
    
    func mainPressed(){
        let mainScene = GameScene(size: self.size)
        let transition = SKTransition.crossFadeWithDuration(0.75)
        mainScene.scaleMode = .AspectFill
        self.scene?.view?.presentScene(mainScene, transition: transition)
        stackView.removeFromSuperview()
        self.view?.viewWithTag(20)?.removeFromSuperview()
        
        
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        
        let newLength = text.utf16.count + string.utf16.count - range.length
        return newLength <= 1 // Bool
    }

}