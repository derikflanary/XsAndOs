////
////  MultiplayerSetupScene.swift
////  XsAndOs
////
////  Created by Derik Flanary on 1/4/16.
////  Copyright © 2016 Derik Flanary. All rights reserved.
////
//
//import Foundation
//import SpriteKit
//import Parse
//
//
//class MultiplayerSetupScene: XandOScene, UITextFieldDelegate {
//    
//    var opponent = PFUser()
//    let startButton = UIButton()
//    let sizeField = UITextField()
//    let label = UILabel()
//    var stackView = UIStackView()
//    let oppLabel = UILabel()
//    let backButton = UIButton()
//    
//    override func didMove(to view: SKView) {
//        super.didMove(to: view)
//        
//        backButton.frame = CGRect(x: 10, y: 20, width: 50, height: 30)
//        backButton.setTitle("Main", for: UIControlState())
//        backButton.setTitleColor(textColor, for: UIControlState())
//        backButton.setTitleColor(UIColor(white: 0.7, alpha: 1), for: .highlighted)
//        backButton.addTarget(self, action: #selector(MultiplayerSetupScene.mainPressed), for: .touchUpInside)
//        backButton.tag = 20
//        self.view?.addSubview(backButton)
//        
//        oppLabel.frame = CGRect(x: 0, y: 150, width: self.view!.frame.size.width, height: 40)
//        oppLabel.numberOfLines = 0
//        let oppName = opponent["name"]
//        oppLabel.text = "Opponent: \(oppName)"
//        oppLabel.textColor = textColor
//        oppLabel.textAlignment = .center
//        
//        startButton.frame = CGRect(x: 0, y: 100, width: (self.view?.frame.size.width)!, height: 50)
//        startButton.setTitle("Start Game", for: UIControlState())
//        startButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
//        startButton.setTitleColor(textColor, for: UIControlState())
//        startButton.setTitleColor(UIColor(white: 0.2, alpha: 0.6), for: .highlighted)
//        startButton.addTarget(self, action: #selector(MultiplayerSetupScene.newGamePressed), for: .touchUpInside)
//        
//        label.frame = CGRect(x: 0, y: 150, width: self.view!.frame.size.width, height: 40)
//        label.numberOfLines = 0
//        label.text = "Choose the number of Rows and Columns (Min:4 | Max:8)"
//        label.textColor = textColor
//        label.textAlignment = .center
//        
//        sizeField.frame = CGRect.zero
//        sizeField.placeholder = "7"
//        sizeField.backgroundColor = flint
//        sizeField.textColor = textColor
//        sizeField.keyboardType = UIKeyboardType.numberPad
//        sizeField.textAlignment = .center
//        sizeField.borderStyle = .roundedRect
//        sizeField.delegate = self
//        
//        stackView = UIStackView(arrangedSubviews: [oppLabel, startButton, label, sizeField])
//        stackView.axis = .vertical
//        stackView.spacing = 20
//        stackView.distribution = .fillEqually
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        self.view?.addSubview(stackView)
//        
//        let margins = self.view?.layoutMarginsGuide
//        stackView.leadingAnchor.constraint(equalTo: (margins?.leadingAnchor)!).isActive = true
//        stackView.trailingAnchor.constraint(equalTo: (margins?.trailingAnchor)!).isActive = true
//        stackView.centerXAnchor.constraint(equalTo: (margins?.centerXAnchor)!).isActive = true
//        stackView.centerYAnchor.constraint(equalTo: (margins?.centerYAnchor)!, constant: -80).isActive = true
//        stackView.heightAnchor.constraint(equalToConstant: 250).isActive = true
//    }
//    
//    func newGamePressed(){
//        print("new game pressed")
//        var dim : Int
//        var rows = Int(sizeField.text!)
//        if rows == nil{
//            dim = 13
//            rows = 7
//        }else{
//            dim = BoardSetupController().calculateDim(rows!)
//        }
//
//        transitionToBoardScene(dim, rows: rows!)
//        stackView.removeFromSuperview()
//        backButton.removeFromSuperview()
//    }
//    
//    fileprivate func transitionToBoardScene(_ dim : Int, rows : Int){
//        
//        XGameController.Singleton.sharedInstance.createNewGame(xTeam: PFUser.currentUser()!, oTeam: opponent, rows: rows, dim: dim) { (success, game, id, xId, oId) -> Void in
//            if success{
//                let secondScene = MultiplayerBoard(size: self.view!.frame.size, theDim: dim, theRows: rows, userTeam: Board.UserTeam.X, aiGame: false)
//                secondScene.xUser = PFUser.currentUser()!
//                secondScene.oUser = self.opponent
//                secondScene.xTurnLoad = true
//                secondScene.scaleMode = SKSceneScaleMode.AspectFill
//                let transition = SKTransition.crossFadeWithDuration(1)
//                secondScene.gameID = id
//                secondScene.xObjId = xId
//                secondScene.oObjId = oId
//                self.scene!.view?.presentScene(secondScene, transition: transition)
//            }
//        }
//    }
//    
//    func mainPressed(){
//        let mainScene = GameScene(size: self.size)
//        let transition = SKTransition.crossFade(withDuration: 0.75)
//        mainScene.scaleMode = .aspectFill
//        self.scene?.view?.presentScene(mainScene, transition: transition)
//        removeViews()
//    }
//    
//    override func removeViews(){
//        stackView.removeFromSuperview()
//        self.view?.viewWithTag(20)?.removeFromSuperview()
//    }
//    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        guard let text = textField.text else { return true }
//        
//        let newLength = text.utf16.count + string.utf16.count - range.length
//        return newLength <= 1 // Bool
//    }
//}
