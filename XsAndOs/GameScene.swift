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

class GameScene: XandOScene, UITextFieldDelegate {
    
    private let startButton = UIButton()
    private let sizeField = UITextField()
    private let label = UILabel()
    private var stackView = UIStackView()
    private let fbLoginbutton = UIButton()
    private let friendButton = UIButton()
    private let currentGamesButton = UIButton()
    var friendsList = [[String:String]]()
    var currentGames = [PFObject]()
    private var activityIndicator = UIActivityIndicatorView()
    let transition = SKTransition.crossFadeWithDuration(1)
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        startButton.frame = CGRectMake(0, 100, (self.view?.frame.size.width)!, 50)
        startButton.setTitle("Start Game", forState: .Normal)
        startButton.titleLabel?.font = UIFont.boldSystemFontOfSize(18)
        startButton.setTitleColor(textColor, forState: .Normal)
        startButton.setTitleColor(UIColor(white: 0.2, alpha: 0.6), forState: .Highlighted)
        startButton.addTarget(self, action: "newGamePressed", forControlEvents: .TouchUpInside)
        
        label.frame = CGRectMake(0, 150, self.view!.frame.size.width, 50)
        label.numberOfLines = 0
        label.text = "Choose the number of Rows and Columns (Min:4 | Max:8)"
        label.font = UIFont.systemFontOfSize(15)
        label.textColor = textColor
        label.textAlignment = .Center
        
        sizeField.frame = CGRectZero
        sizeField.backgroundColor = flint
        sizeField.textColor = textColor
        sizeField.placeholder = "7"
        sizeField.keyboardType = UIKeyboardType.NumberPad
        sizeField.textAlignment = .Center
        sizeField.borderStyle = .RoundedRect
        sizeField.delegate = self
        
        fbLoginbutton.frame = CGRectZero
        fbLoginbutton.setTitle("Log in with Facebook", forState: .Normal)
        fbLoginbutton.titleLabel?.font = UIFont.boldSystemFontOfSize(16)
        fbLoginbutton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        fbLoginbutton.setTitleColor(UIColor(white: 0.2, alpha: 0.6), forState: .Highlighted)
        fbLoginbutton.addTarget(self, action: "fbLoginPressed", forControlEvents: .TouchUpInside)
        
        friendButton.frame = CGRectZero
        friendButton.setTitle("Play with Friends", forState: .Normal)
        friendButton.titleLabel?.font = UIFont.boldSystemFontOfSize(16)
        friendButton.setTitleColor(blu, forState: .Normal)
        friendButton.setTitleColor(UIColor(white: 0.2, alpha: 0.6), forState: .Highlighted)
        friendButton.addTarget(self, action: "friendPressed", forControlEvents: .TouchUpInside)
        
        currentGamesButton.frame = CGRectZero
        currentGamesButton.setTitle("Current Games", forState: .Normal)
        currentGamesButton.titleLabel?.font = UIFont.boldSystemFontOfSize(16)
        currentGamesButton.setTitleColor(blu, forState: .Normal)
        currentGamesButton.setTitleColor(UIColor(white: 0.2, alpha: 0.6), forState: .Highlighted)
        currentGamesButton.addTarget(self, action: "currentGamesPressed", forControlEvents: .TouchUpInside)
        currentGamesButton.highlighted = true
        currentGamesButton.enabled = false
        
        if PFUser.currentUser() != nil{
            stackView = UIStackView(arrangedSubviews: [startButton, label, sizeField, friendButton, currentGamesButton])
            friendsList = (PFUser.currentUser()?.valueForKey("friends"))! as! [[String : String]]
            checkCurrentGames()
            let myinstallation = PFInstallation.currentInstallation()
            myinstallation.setObject((PFUser.currentUser()?.username)!, forKey: "ownerUsername")
            myinstallation.saveInBackground()
        }else{
            stackView = UIStackView(arrangedSubviews: [startButton, label, sizeField, fbLoginbutton, currentGamesButton])
        }
        stackView.axis = .Vertical
        stackView.spacing = 16
        stackView.distribution = .EqualSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.view?.addSubview(stackView)
        
        let margins = self.view?.layoutMarginsGuide
        stackView.leadingAnchor.constraintEqualToAnchor(margins?.leadingAnchor).active = true
        stackView.trailingAnchor.constraintEqualToAnchor(margins?.trailingAnchor).active = true
        stackView.centerXAnchor.constraintEqualToAnchor(margins?.centerXAnchor).active = true
        stackView.centerYAnchor.constraintEqualToAnchor(margins?.centerYAnchor, constant: -80).active = true
        stackView.heightAnchor.constraintEqualToConstant(260).active = true
    }
    
    override init(size: CGSize) {
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    private func transitionToBoardScene(dim : Int, rows : Int){
        let secondScene = Board(size: self.view!.frame.size, theDim: dim, theRows: rows)
        secondScene.scaleMode = SKSceneScaleMode.AspectFill
        self.scene!.view?.presentScene(secondScene, transition: transition)
    }
    
    func fbLoginPressed(){
        print("fbLoginPressed")
        FacebookController.Singleton.sharedInstance.loginToFacebook { (success, friendList) -> Void in
            if success{
                //update the UI here
                let myinstallation = PFInstallation.currentInstallation()
                myinstallation.setObject((PFUser.currentUser()?.username)!, forKey: "ownerUsername")
                myinstallation.saveInBackground()
                
                dispatch_async(dispatch_get_main_queue(),{
                    self.friendsList = friendList
                    self.stackView.removeArrangedSubview(self.fbLoginbutton)
                    self.fbLoginbutton.removeFromSuperview()
                    self.stackView.addArrangedSubview(self.friendButton)
                })
            }else{
                self.fbLoginbutton.enabled = true
            }
        }
        self.fbLoginbutton.enabled = false
        fbLoginbutton.setTitleColor(UIColor(white: 0.2, alpha: 0.8), forState: .Normal)
    }
    
    func friendPressed(){
        transitionToFriendList(friendsList)
    }
    
    func checkCurrentGames(){
        XGameController.Singleton.sharedInstance.fetchGamesForUser(PFUser.currentUser()!) { (success, games) -> Void in
            guard success else{return}
            if games.count > 0{
                dispatch_async(dispatch_get_main_queue(),{
                    self.currentGames = games
                    self.currentGamesButton.enabled = true
                    self.currentGamesButton.highlighted = false
                })
            }
        }
    }
    
    func currentGamesPressed(){
        transitionToCurrentGames(currentGames)
    }
    
    private func transitionToFriendList(friendList : [[String:String]]){
        stackView.removeFromSuperview()
        let secondScene = FriendListScene()
        secondScene.friends = friendList
        secondScene.scaleMode = SKSceneScaleMode.AspectFill
        self.scene!.view?.presentScene(secondScene, transition: transition)

    }
    
    private func transitionToCurrentGames(games : [PFObject]){
        stackView.removeFromSuperview()
        let secondScene = CurrentGamesScene()
        secondScene.games = currentGames
        secondScene.scaleMode = SKSceneScaleMode.AspectFill
        self.scene!.view?.presentScene(secondScene, transition: transition)
    }
    
    override func removeViews(){
        stackView.removeFromSuperview()
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.utf16.count + string.utf16.count - range.length
        return newLength <= 1 // Bool
    }
    

}
