//
//  SingleSetupScene.swift
//  XsAndOs
//
//  Created by Derik Flanary on 2/10/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation
import SpriteKit
import Parse

class SingleSetupScene: XandOScene, UITextFieldDelegate {
    
    enum GameType {
        case AI
        case Local
        case Online
    }
    
    //MARK: - PROPERTIES
    private let startButton = SButton()
    private let sizeField = UITextField()
    private var stackView = UIStackView()
    private var localStackView = UIStackView()
    private var innerStack = UIStackView()
    private var difficultyStack = UIStackView()
    private var rowStack = UIStackView()
    private let xButton = Button()
    private let oButton = Button()
    private let rowsLabel = InfoLabel(frame: CGRectZero)
    private let teamLabel = InfoLabel(frame: CGRectZero)
    private let difficultyLabel = InfoLabel(frame: CGRectZero)
    private let opponentLabel = InfoLabel(frame: CGRectZero)
    private let easyButton = Button()
    private let moderateButton = Button()
    private let hardButton = Button()
    private let backButton = Button()
    var opponent : PFUser?
    var userTeam = Board.UserTeam.X
    var difficulty = Difficulty.Moderate
    var type : GameType
    private var rowButtons = [Button]()
    var r : Int = 6
    
    //MARK: - INIT
    init(size: CGSize, type: GameType) {
        self.type = type
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - VIEW SETUP
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        layoutViews()
    }
    
    private func layoutViews(){
        startButton.frame = CGRectMake(20, (self.view?.center.y)! - 80, (self.view?.bounds.size.width)! - 40, 50)
        startButton.center.x = (self.view?.center.x)!
        startButton.setTitle("Start", forState: .Normal)
        startButton.addTarget(self, action: "newGamePressed", forControlEvents: .TouchUpInside)
        startButton.titleLabel?.font = UIFont(name: boldFontName, size: 36)
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
        
        easyButton.setImage(UIImage(named: "x1"), forState: .Normal)
        easyButton.layer.cornerRadius = 25
        easyButton.clipsToBounds = true
        easyButton.imageView?.contentMode = .Center
        easyButton.backgroundColor = flint
        easyButton.addTarget(self, action: "easyPressed", forControlEvents: .TouchUpInside)
        
        moderateButton.setImage(UIImage(named: "xx"), forState: .Normal)
        moderateButton.layer.cornerRadius = 25
        moderateButton.clipsToBounds = true
        moderateButton.imageView?.contentMode = .Center
        moderateButton.backgroundColor = oColor
        moderateButton.addTarget(self, action: "moderatePressed", forControlEvents: .TouchUpInside)
        
        hardButton.setImage(UIImage(named: "xxx"), forState: .Normal)
        hardButton.layer.cornerRadius = 25
        hardButton.clipsToBounds = true
        hardButton.imageView?.contentMode = .Center
        hardButton.backgroundColor = flint
        hardButton.addTarget(self, action: "hardPressed", forControlEvents: .TouchUpInside)
        
        rowsLabel.text = "Rows"
        teamLabel.text = "Team"
        difficultyLabel.text = "Difficulty"
        
        backButton.frame = CGRectMake(10, 20, 50, 50)
        backButton.backgroundColor = xColor
        backButton.setImage(UIImage(named: "home"), forState: .Normal)
        backButton.imageView?.contentMode = .Center
        backButton.addTarget(self, action: "mainPressed", forControlEvents: .TouchUpInside)
        
        createRowsStack()
        
        switch type{
        case .AI:
            addAIStackViews()
        case .Local:
            addLocalStackViews()
        case .Online:
            if opponent != nil{
                opponentLabel.text = "VS: \(opponent!["name"])"
                opponentLabel.font = UIFont(name: boldFontName, size: 20)
                opponentLabel.textColor = oColor
            }
            addOnlineStackViews()
        }
        
        animateInStackView()
        
    }
    
    private func createRowsStack(){
        for i in 4...8 {
            let button = Button()
            button.setTitle(String(i), forState: .Normal)
            button.titleLabel?.font = UIFont(name: boldFontName, size: 24)
            button.backgroundColor = flint
            button.tag = i
            button.addTarget(self, action: "rowButtonPressed:", forControlEvents: .TouchUpInside)
            button.widthAnchor.constraintEqualToConstant(50).active = true
            button.heightAnchor.constraintEqualToConstant(50).active = true
            if i == r{ button.backgroundColor = thirdColor}
            rowButtons.append(button)
        }
        rowStack = UIStackView(arrangedSubviews: rowButtons)
        rowStack.axis = .Horizontal
        rowStack.alignment = .Center
        rowStack.distribution = .EqualSpacing
        rowStack.spacing = 21
        
    }
    
    private func addLocalStackViews(){
    
        localStackView = UIStackView(arrangedSubviews: [backButton, startButton, rowsLabel, rowStack])
        localStackView.axis = .Vertical
        localStackView.alignment = .Center
        localStackView.spacing = 21
        localStackView.distribution = .EqualSpacing
        localStackView.translatesAutoresizingMaskIntoConstraints = false
        localStackView.alpha = 1
        self.view?.addSubview(localStackView)

        addLocalTypeAutoContraints()
    }
    
    private func addAIStackViews(){
        
        innerStack = UIStackView(arrangedSubviews: [xButton, oButton])
        innerStack.axis = .Horizontal
        innerStack.alignment = .Center
        innerStack.distribution = .FillEqually
        innerStack.spacing = 50
        
        difficultyStack = UIStackView(arrangedSubviews: [easyButton, moderateButton, hardButton])
        difficultyStack.axis = .Horizontal
        difficultyStack.alignment = .Center
        difficultyStack.distribution = .FillEqually
        difficultyStack.spacing = 20

        stackView = UIStackView(arrangedSubviews: [backButton, startButton, rowsLabel, rowStack, teamLabel, innerStack, difficultyLabel, difficultyStack])
        stackView.axis = .Vertical
        stackView.alignment = .Center
        stackView.spacing = 21
        stackView.distribution = .EqualSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alpha = 0
        self.view?.addSubview(stackView)
        
        addAITypeAutoContraints()
    }
    
    private func addOnlineStackViews(){
        innerStack = UIStackView(arrangedSubviews: [xButton, oButton])
        innerStack.axis = .Horizontal
        innerStack.alignment = .Center
        innerStack.distribution = .FillEqually
        innerStack.spacing = 50
        
        stackView = UIStackView(arrangedSubviews: [backButton,opponentLabel, startButton, rowsLabel, rowStack, teamLabel, innerStack])
        stackView.axis = .Vertical
        stackView.alignment = .Center
        stackView.spacing = 21
        stackView.distribution = .EqualSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alpha = 0
        self.view?.addSubview(stackView)
        
        addAITypeAutoContraints()

    }
    //MARK: - AUTOCONTRAINTS
    private func addLocalTypeAutoContraints(){
        let margins = self.view?.layoutMarginsGuide
        localStackView.leadingAnchor.constraintEqualToAnchor(margins?.leadingAnchor).active = true
        localStackView.trailingAnchor.constraintEqualToAnchor(margins?.trailingAnchor).active = true
        localStackView.centerXAnchor.constraintEqualToAnchor(margins?.centerXAnchor).active = true
        localStackView.centerYAnchor.constraintEqualToAnchor(margins?.centerYAnchor, constant: 0).active = true
        localStackView.heightAnchor.constraintEqualToConstant(300).active = true
        addMainAutoContraints()
    }
    
    private func addMainAutoContraints(){
        let margins = self.view?.layoutMarginsGuide
        startButton.heightAnchor.constraintEqualToConstant(50).active = true
        startButton.widthAnchor.constraintGreaterThanOrEqualToAnchor(margins?.widthAnchor).active = true
        sizeField.widthAnchor.constraintEqualToConstant(100).active = true
        sizeField.heightAnchor.constraintEqualToConstant(100).active = true
        backButton.widthAnchor.constraintEqualToConstant(50).active = true
        backButton.heightAnchor.constraintEqualToConstant(50).active = true
    }
    
    private func addAITypeAutoContraints(){
        let margins = self.view?.layoutMarginsGuide
        stackView.leadingAnchor.constraintEqualToAnchor(margins?.leadingAnchor).active = true
        stackView.trailingAnchor.constraintEqualToAnchor(margins?.trailingAnchor).active = true
        stackView.centerXAnchor.constraintEqualToAnchor(margins?.centerXAnchor).active = true
        stackView.centerYAnchor.constraintEqualToAnchor(margins?.centerYAnchor, constant: 0).active = true
        stackView.heightAnchor.constraintEqualToAnchor(margins?.heightAnchor, constant: -140).active = true

        xButton.widthAnchor.constraintEqualToConstant(80).active = true
        xButton.heightAnchor.constraintEqualToConstant(80).active = true
        oButton.widthAnchor.constraintEqualToConstant(80).active = true
        oButton.heightAnchor.constraintEqualToConstant(80).active = true
        easyButton.heightAnchor.constraintEqualToConstant(50).active = true
        easyButton.widthAnchor.constraintEqualToConstant(100).active = true
        moderateButton.heightAnchor.constraintEqualToConstant(50).active = true
        moderateButton.widthAnchor.constraintEqualToConstant(100).active = true
        hardButton.heightAnchor.constraintEqualToConstant(50).active = true
        hardButton.widthAnchor.constraintEqualToConstant(100).active = true
        
        addMainAutoContraints()
    }
    
    private func addOnlineTypeAutoContraints(){
        let margins = self.view?.layoutMarginsGuide
        stackView.leadingAnchor.constraintEqualToAnchor(margins?.leadingAnchor).active = true
        stackView.trailingAnchor.constraintEqualToAnchor(margins?.trailingAnchor).active = true
        stackView.centerXAnchor.constraintEqualToAnchor(margins?.centerXAnchor).active = true
        stackView.centerYAnchor.constraintEqualToAnchor(margins?.centerYAnchor, constant: 0).active = true
        stackView.heightAnchor.constraintEqualToAnchor(margins?.heightAnchor, constant: -140).active = true

        xButton.widthAnchor.constraintEqualToConstant(80).active = true
        xButton.heightAnchor.constraintEqualToConstant(80).active = true
        oButton.widthAnchor.constraintEqualToConstant(80).active = true
        oButton.heightAnchor.constraintEqualToConstant(80).active = true
        
        addMainAutoContraints()
    }
    
    //MARK: - TOUCHES
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view?.endEditing(true)

    }
    
    //MARK: - BUTTON METHODS
    func xPressed(){
        buttonSoundEffect.play()
        animateXButtonPress()
        userTeam = .X
    }
    
    func oPressed(){
        buttonSoundEffect.play()
        animateOButtonPress()
        userTeam = .O
    }
    
    func newGamePressed(){
        buttonSoundEffect.play()
        var dim : Int
        dim = BoardSetupController().calculateDim(r)
        transitionToBoardScene(dim, rows: r)
    }

    func easyPressed(){
        buttonSoundEffect.play()
        animateDifficultyButtonPress(easyButton, button1: moderateButton, button2: hardButton)
        difficulty = .Easy
    }
    
    func moderatePressed(){
        buttonSoundEffect.play()
        animateDifficultyButtonPress(moderateButton, button1: easyButton, button2: hardButton)
        difficulty = .Moderate
    }
    
    func hardPressed(){
        buttonSoundEffect.play()
        animateDifficultyButtonPress(hardButton, button1: easyButton, button2: moderateButton)
        difficulty = .Hard
    }
    
    func mainPressed(){
        buttonSoundEffect.play()
        removeViews()
        transitionToMainScene()
    }
    
    func rowButtonPressed(sender: Button){
        buttonSoundEffect.play()        
        let oldButton = rowButtons[r - 4]
        animateRowButtonPress(sender, button1: oldButton)
        r = sender.tag
    }

    //MARK: - TRANSITIONS
    private func transitionToBoardScene(dim : Int, rows : Int){
        var aiGame = false
        if type == .AI{
            aiGame = true
        }
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.stackView.alpha = 0
            self.localStackView.alpha = 0
            self.view?.viewWithTag(1000)?.alpha = 0
        }) { (done) -> Void in
            if self.type == .Online{
               self.transitionToOnlineBoardScene(dim, rows: rows)
            }else{
                let secondScene = Board(size: self.view!.frame.size, theDim: dim, theRows: rows, userTeam: self.userTeam, aiGame: aiGame, difficulty: self.difficulty)
                secondScene.scaleMode = SKSceneScaleMode.AspectFill
                self.scene!.view?.presentScene(secondScene, transition: transition)
            }
            self.removeViews()
        }
    }
    
    private func transitionToOnlineBoardScene(dim : Int, rows : Int){
        var oTeam = opponent
        var xTeam = PFUser.currentUser()
        if self.userTeam.rawValue == o{
            oTeam = PFUser.currentUser()
            xTeam = opponent
        }
        XGameController.Singleton.sharedInstance.createNewGame(xTeam: xTeam!, oTeam: oTeam!, rows: rows, dim: dim) { (success, game, id, xId, oId) -> Void in
            if success{
                let secondScene = MultiplayerBoard(size: (self.view?.frame.size)!, theDim: dim, theRows: rows, userTeam: self.userTeam, aiGame: false)
                secondScene.xUser = xTeam!
                secondScene.oUser = oTeam!
                
                secondScene.xTurnLoad = true
                secondScene.scaleMode = SKSceneScaleMode.AspectFill
                let transition = SKTransition.crossFadeWithDuration(1)
                secondScene.gameID = id
                secondScene.xObjId = xId
                secondScene.oObjId = oId
                self.scene!.view?.presentScene(secondScene, transition: transition)
            }
        }
    }

    
    func transitionToMainScene(){
        let mainScene = MainScene(size: self.size)
        self.scene?.view?.presentScene(mainScene)
    }
    
    //MARK: - CLEAN UP
    override func removeViews() {
        stackView.removeFromSuperview()
        localStackView.removeFromSuperview()
        backButton.removeFromSuperview()
    }
    
    //MARK: - ANIMATIONS
    

    private func animateInStackView(){
        UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: .CurveEaseInOut, animations: { () -> Void in
            self.stackView.alpha = 1
            self.localStackView.alpha = 1
            }) { (done) -> Void in
        }
    }

    func animateDifficultyButtonPress(pressedButton: UIButton, button1: UIButton, button2: UIButton){
        UIView.animateWithDuration(0.25) { () -> Void in
            pressedButton.backgroundColor = oColor
            button1.backgroundColor = flint
            button2.backgroundColor = flint
            pressedButton.alpha = 1
            button1.alpha = 1
            button2.alpha = 1
        }
    }
    
    func animateRowButtonPress(pressedButton: UIButton, button1: UIButton){
        UIView.animateWithDuration(0.25) { () -> Void in
            pressedButton.backgroundColor = thirdColor
            button1.backgroundColor = flint
        }
    }
    
    func animateXButtonPress(){
        UIView.animateWithDuration(0.25) { () -> Void in
            self.oButton.backgroundColor = flint
            self.xButton.backgroundColor = xColor
        }
    }
    
    func animateOButtonPress(){
        UIView.animateWithDuration(0.25) { () -> Void in
            self.oButton.backgroundColor = oColor
            self.xButton.backgroundColor = flint
        }
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
        self.font = UIFont(name: boldFontName, size: 24)
        self.textColor = UIColor(red: 0.78, green: 0.81, blue: 0.83, alpha: 1.0)
        self.textAlignment = .Center
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}