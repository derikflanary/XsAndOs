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
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class SingleSetupScene: XandOScene, UITextFieldDelegate {
    
    enum GameType {
        case ai
        case local
        case online
    }
    
    //MARK: - PROPERTIES
    fileprivate let startButton = SButton()
    fileprivate let sizeField = UITextField()
    fileprivate var stackView = UIStackView()
    fileprivate var localStackView = UIStackView()
    fileprivate var innerStack = UIStackView()
    fileprivate var difficultyStack = UIStackView()
    fileprivate var rowStack = UIStackView()
    fileprivate let xButton = Button()
    fileprivate let oButton = Button()
    fileprivate let rowsLabel = InfoLabel(frame: CGRect.zero)
    fileprivate let teamLabel = InfoLabel(frame: CGRect.zero)
    fileprivate let difficultyLabel = InfoLabel(frame: CGRect.zero)
    fileprivate let opponentLabel = InfoLabel(frame: CGRect.zero)
    fileprivate let easyButton = Button()
    fileprivate let moderateButton = Button()
    fileprivate let hardButton = Button()
    fileprivate let backButton = Button()
    var opponent : PFUser?
    var userTeam = Board.UserTeam.X
    var difficulty = Difficulty.moderate
    var type : GameType
    fileprivate var rowButtons = [Button]()
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
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        layoutViews()
    }
    
    fileprivate func layoutViews(){
        startButton.frame = CGRect(x: 20, y: (self.view?.center.y)! - 80, width: (self.view?.bounds.size.width)! - 40, height: 50)
        startButton.center.x = (self.view?.center.x)!
        startButton.setTitle("Start", for: UIControlState())
        startButton.addTarget(self, action: #selector(SingleSetupScene.newGamePressed), for: .touchUpInside)
        startButton.titleLabel?.font = UIFont(name: boldFontName, size: 36)
        startButton.backgroundColor = xColor
                
        sizeField.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        sizeField.backgroundColor = textColor
        sizeField.textColor = thirdColor
        sizeField.font = UIFont(name: boldFontName, size: 50)
        sizeField.placeholder = "7"
        sizeField.keyboardType = UIKeyboardType.numberPad
        sizeField.textAlignment = .center
        sizeField.borderStyle = .roundedRect
        sizeField.layer.cornerRadius = 50
        sizeField.clipsToBounds = true
        sizeField.delegate = self

        xButton.setImage(UIImage(named: "ex"), for: UIControlState())
        xButton.backgroundColor = xColor
        xButton.imageView?.contentMode = .center
        xButton.layer.cornerRadius = 40
        xButton.clipsToBounds = true
        xButton.addTarget(self, action: #selector(SingleSetupScene.xPressed), for: .touchUpInside)
        
        oButton.setImage(UIImage(named: "oh"), for: UIControlState())
        oButton.backgroundColor = flint
        oButton.imageView?.contentMode = .center
        oButton.layer.cornerRadius = 40
        oButton.clipsToBounds = true
        oButton.addTarget(self, action: #selector(SingleSetupScene.oPressed), for: .touchUpInside)
        
        easyButton.setImage(UIImage(named: "x1"), for: UIControlState())
        easyButton.layer.cornerRadius = 25
        easyButton.clipsToBounds = true
        easyButton.imageView?.contentMode = .center
        easyButton.backgroundColor = flint
        easyButton.addTarget(self, action: #selector(SingleSetupScene.easyPressed), for: .touchUpInside)
        
        moderateButton.setImage(UIImage(named: "xx"), for: UIControlState())
        moderateButton.layer.cornerRadius = 25
        moderateButton.clipsToBounds = true
        moderateButton.imageView?.contentMode = .center
        moderateButton.backgroundColor = oColor
        moderateButton.addTarget(self, action: #selector(SingleSetupScene.moderatePressed), for: .touchUpInside)
        
        hardButton.setImage(UIImage(named: "xxx"), for: UIControlState())
        hardButton.layer.cornerRadius = 25
        hardButton.clipsToBounds = true
        hardButton.imageView?.contentMode = .center
        hardButton.backgroundColor = flint
        hardButton.addTarget(self, action: #selector(SingleSetupScene.hardPressed), for: .touchUpInside)
        
        rowsLabel.text = "Rows"
        teamLabel.text = "Team"
        difficultyLabel.text = "Difficulty"
        
        backButton.frame = CGRect(x: 10, y: 20, width: 50, height: 50)
        backButton.backgroundColor = xColor
        backButton.setImage(UIImage(named: "home"), for: UIControlState())
        backButton.imageView?.contentMode = .center
        backButton.addTarget(self, action: #selector(SingleSetupScene.mainPressed), for: .touchUpInside)
        
        createRowsStack()
        
        switch type{
        case .ai:
            addAIStackViews()
        case .local:
            addLocalStackViews()
        case .online:
            if opponent != nil{
                opponentLabel.text = "VS: \(opponent!["name"])"
                opponentLabel.font = UIFont(name: boldFontName, size: 20)
                opponentLabel.textColor = oColor
            }
            addOnlineStackViews()
        }
        
        animateInStackView()
        
    }
    
    fileprivate func createRowsStack(){
        for i in 4...8 {
            let button = Button()
            button.setTitle(String(i), for: UIControlState())
            button.titleLabel?.font = UIFont(name: boldFontName, size: 24)
            button.backgroundColor = flint
            button.tag = i
            button.addTarget(self, action: #selector(SingleSetupScene.rowButtonPressed(_:)), for: .touchUpInside)
            button.widthAnchor.constraint(equalToConstant: 50).isActive = true
            button.heightAnchor.constraint(equalToConstant: 50).isActive = true
            if i == r{ button.backgroundColor = thirdColor}
            rowButtons.append(button)
        }
        rowStack = UIStackView(arrangedSubviews: rowButtons)
        rowStack.axis = .horizontal
        rowStack.alignment = .center
        rowStack.distribution = .equalSpacing
        rowStack.spacing = 21
        if UIScreen.main.bounds.width == 320{
            rowStack.spacing = 8
        }
        
    }
    
    fileprivate func addLocalStackViews(){
    
        localStackView = UIStackView(arrangedSubviews: [backButton, startButton, rowsLabel, rowStack])
        localStackView.axis = .vertical
        localStackView.alignment = .center
        localStackView.spacing = 21
        localStackView.distribution = .equalSpacing
        localStackView.translatesAutoresizingMaskIntoConstraints = false
        localStackView.alpha = 1
        self.view?.addSubview(localStackView)

        addLocalTypeAutoContraints()
    }
    
    fileprivate func addAIStackViews(){
        
        innerStack = UIStackView(arrangedSubviews: [xButton, oButton])
        innerStack.axis = .horizontal
        innerStack.alignment = .center
        innerStack.distribution = .fillEqually
        innerStack.spacing = 50
        
        difficultyStack = UIStackView(arrangedSubviews: [easyButton, moderateButton, hardButton])
        difficultyStack.axis = .horizontal
        difficultyStack.alignment = .center
        difficultyStack.distribution = .fillEqually
        difficultyStack.spacing = 20

        stackView = UIStackView(arrangedSubviews: [backButton, startButton, rowsLabel, rowStack, teamLabel, innerStack, difficultyLabel, difficultyStack])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 21
        if UIScreen.main.bounds.width == 320{
            stackView.spacing = 11
        }
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alpha = 0
        self.view?.addSubview(stackView)
        
        addAITypeAutoContraints()
    }
    
    fileprivate func addOnlineStackViews(){
        innerStack = UIStackView(arrangedSubviews: [xButton, oButton])
        innerStack.axis = .horizontal
        innerStack.alignment = .center
        innerStack.distribution = .fillEqually
        innerStack.spacing = 50
        
        stackView = UIStackView(arrangedSubviews: [backButton,opponentLabel, startButton, rowsLabel, rowStack, teamLabel, innerStack])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 21
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alpha = 0
        self.view?.addSubview(stackView)
        
        addAITypeAutoContraints()

    }
    //MARK: - AUTOCONTRAINTS
    fileprivate func addLocalTypeAutoContraints(){
        let margins = self.view?.layoutMarginsGuide
        localStackView.leadingAnchor.constraint(equalTo: (margins?.leadingAnchor)!).isActive = true
        localStackView.trailingAnchor.constraint(equalTo: (margins?.trailingAnchor)!).isActive = true
        localStackView.centerXAnchor.constraint(equalTo: (margins?.centerXAnchor)!).isActive = true
        localStackView.centerYAnchor.constraint(equalTo: (margins?.centerYAnchor)!, constant: 0).isActive = true
        localStackView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        addMainAutoContraints()
    }
    
    fileprivate func addMainAutoContraints(){
        let margins = self.view?.layoutMarginsGuide
        startButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        startButton.widthAnchor.constraint(greaterThanOrEqualTo: (margins?.widthAnchor)!).isActive = true
        sizeField.widthAnchor.constraint(equalToConstant: 100).isActive = true
        sizeField.heightAnchor.constraint(equalToConstant: 100).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    fileprivate func addAITypeAutoContraints(){
        let margins = self.view?.layoutMarginsGuide
        stackView.leadingAnchor.constraint(equalTo: (margins?.leadingAnchor)!).isActive = true
        stackView.trailingAnchor.constraint(equalTo: (margins?.trailingAnchor)!).isActive = true
        stackView.centerXAnchor.constraint(equalTo: (margins?.centerXAnchor)!).isActive = true
        stackView.centerYAnchor.constraint(equalTo: (margins?.centerYAnchor)!, constant: 0).isActive = true
        stackView.heightAnchor.constraint(equalTo: (margins?.heightAnchor)!, constant: -100).isActive = true
        
        var width : CGFloat = 80
        if UIScreen.main.bounds.width == 320{
            width = 60
        }
        xButton.widthAnchor.constraint(equalToConstant: width).isActive = true
        xButton.heightAnchor.constraint(equalToConstant: width).isActive = true
        oButton.widthAnchor.constraint(equalToConstant: width).isActive = true
        oButton.heightAnchor.constraint(equalToConstant: width).isActive = true
        
        easyButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        easyButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        moderateButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        moderateButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        hardButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        hardButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        addMainAutoContraints()
    }
    
    fileprivate func addOnlineTypeAutoContraints(){
        let margins = self.view?.layoutMarginsGuide
        stackView.leadingAnchor.constraint(equalTo: (margins?.leadingAnchor)!).isActive = true
        stackView.trailingAnchor.constraint(equalTo: (margins?.trailingAnchor)!).isActive = true
        stackView.centerXAnchor.constraint(equalTo: (margins?.centerXAnchor)!).isActive = true
        stackView.centerYAnchor.constraint(equalTo: (margins?.centerYAnchor)!, constant: 0).isActive = true
        stackView.heightAnchor.constraint(equalTo: (margins?.heightAnchor)!, constant: -140).isActive = true

        xButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        xButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
        oButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        oButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        addMainAutoContraints()
    }
    
    //MARK: - TOUCHES
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
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
        difficulty = .easy
    }
    
    func moderatePressed(){
        buttonSoundEffect.play()
        animateDifficultyButtonPress(moderateButton, button1: easyButton, button2: hardButton)
        difficulty = .moderate
    }
    
    func hardPressed(){
        buttonSoundEffect.play()
        animateDifficultyButtonPress(hardButton, button1: easyButton, button2: moderateButton)
        difficulty = .hard
    }
    
    func mainPressed(){
        buttonSoundEffect.play()
        removeViews()
        if type == .online{
            transitionsToOnlineScene()
        }else{
            transitionToMainScene()
        }
    }
    
    func rowButtonPressed(_ sender: Button){
        buttonSoundEffect.play()        
        let oldButton = rowButtons[r - 4]
        animateRowButtonPress(sender, button1: oldButton)
        r = sender.tag
    }

    //MARK: - TRANSITIONS
    fileprivate func transitionToBoardScene(_ dim : Int, rows : Int){
        var aiGame = false
        if type == .ai{
            aiGame = true
        }
        UIView.animate(withDuration: 1.0, animations: { () -> Void in
            self.stackView.alpha = 0
            self.localStackView.alpha = 0
            self.view?.viewWithTag(1000)?.alpha = 0
        }, completion: { (done) -> Void in
            if self.type == .online{
               self.transitionToOnlineBoardScene(dim, rows: rows)
            }else{
                let secondScene = Board(size: self.view!.frame.size, theDim: dim, theRows: rows, userTeam: self.userTeam, aiGame: aiGame, difficulty: self.difficulty)
                secondScene.scaleMode = SKSceneScaleMode.aspectFill
                self.scene!.view?.presentScene(secondScene, transition: transition)
            }
            self.removeViews()
        }) 
    }
    
    fileprivate func transitionToOnlineBoardScene(_ dim : Int, rows : Int){
//        var oTeam = opponent
//        var xTeam = PFUser.current()
//        if self.userTeam.rawValue == o{
//            oTeam = PFUser.current()
//            xTeam = opponent
//        }
//        XGameController.Singleton.sharedInstance.createNewGame(xTeam: xTeam!, oTeam: oTeam!, rows: rows, dim: dim) { (success, game, id, xId, oId) -> Void in
//            if success{
//                let secondScene = MultiplayerBoard(size: (self.view?.frame.size)!, theDim: dim, theRows: rows, userTeam: self.userTeam, aiGame: false)
//                secondScene.xUser = xTeam!
//                secondScene.oUser = oTeam!
//                
//                secondScene.xTurnLoad = true
//                secondScene.scaleMode = SKSceneScaleMode.AspectFill
//                let transition = SKTransition.crossFadeWithDuration(1)
//                secondScene.gameID = id
//                secondScene.xObjId = xId
//                secondScene.oObjId = oId
//                self.scene!.view?.presentScene(secondScene, transition: transition)
//            }
//        }
    }

    
    func transitionToMainScene(){
        let mainScene = MainScene(size: self.size)
        self.scene?.view?.presentScene(mainScene)
    }
    
    func transitionsToOnlineScene(){
//        let mainScene = GameScene(size: self.size)
//        self.scene?.view?.presentScene(mainScene)
    }
    
    //MARK: - CLEAN UP
    override func removeViews() {
        stackView.removeFromSuperview()
        localStackView.removeFromSuperview()
        backButton.removeFromSuperview()
    }
    
    //MARK: - ANIMATIONS
    

    fileprivate func animateInStackView(){
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: UIViewAnimationOptions(), animations: { () -> Void in
            self.stackView.alpha = 1
            self.localStackView.alpha = 1
            }) { (done) -> Void in
        }
    }

    func animateDifficultyButtonPress(_ pressedButton: UIButton, button1: UIButton, button2: UIButton){
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            pressedButton.backgroundColor = oColor
            button1.backgroundColor = flint
            button2.backgroundColor = flint
            pressedButton.alpha = 1
            button1.alpha = 1
            button2.alpha = 1
        }) 
    }
    
    func animateRowButtonPress(_ pressedButton: UIButton, button1: UIButton){
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            pressedButton.backgroundColor = thirdColor
            button1.backgroundColor = flint
        }) 
    }
    
    func animateXButtonPress(){
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.oButton.backgroundColor = flint
            self.xButton.backgroundColor = xColor
        }) 
    }
    
    func animateOButtonPress(){
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.oButton.backgroundColor = oColor
            self.xButton.backgroundColor = flint
        }) 
    }

    //MARK: - TEXTFIELD DELEGATE
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.utf16.count + string.utf16.count - range.length
        return newLength <= 1 // Bool
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
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
        self.textAlignment = .center
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
