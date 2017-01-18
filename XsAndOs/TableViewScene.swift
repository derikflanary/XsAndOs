////
////  TableViewScene.swift
////  XsAndOs
////
////  Created by Derik Flanary on 1/5/16.
////  Copyright © 2016 Derik Flanary. All rights reserved.
////
//
//import Foundation
//import SpriteKit
//import Parse 
//
//class TableViewScene: XandOScene, UITableViewDataSource, UITableViewDelegate {
//    
//    var tableView = UITableView()
//    var cancelButton = Button()
//    
//    override func didMove(to view: SKView) {
//        super.didMove(to: view)
//        self.backgroundColor = backColor
//        
//        cancelButton.frame = CGRect(x: self.view!.frame.size.width/2 - 50, y: 20, width: 100, height: 30)
//        cancelButton.setTitle("Cancel", for: UIControlState())
//        cancelButton.titleLabel?.font = UIFont(name: boldFontName, size: 18)
//        cancelButton.backgroundColor = xColor
//        cancelButton.addTarget(self, action: #selector(TableViewScene.cancelPressed), for: .touchUpInside)
//        self.view?.addSubview(cancelButton)
//        
//        tableView = UITableView(frame: CGRect(x: 10, y: 50, width: self.view!.frame.size.width - 20, height: self.view!.frame.size.height - 50), style: .grouped)
//        tableView.backgroundColor = backgroundColor
//        tableView.dataSource = self
//        tableView.delegate = self
//        tableView.backgroundColor = UIColor.clear
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
//        tableView.register(GameTableViewCell.self, forCellReuseIdentifier: "GameCell")
//        tableView.separatorStyle = .none
//        self.view!.addSubview(tableView)
//        tableView.reloadData()
//    }
//
//    func cancelPressed(){
//        removeViews()
//        let mainScene = GameScene(size: self.size)
//        let transition = SKTransition.crossFade(withDuration: 0.75)
//        mainScene.scaleMode = .aspectFill
//        self.scene?.view?.presentScene(mainScene, transition: transition)
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 0
//    }
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return ""
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
//        
//        return cell
//    }
//    
//    override func removeViews(){
//        tableView.removeFromSuperview()
//        cancelButton.removeFromSuperview()
//    }
//}
