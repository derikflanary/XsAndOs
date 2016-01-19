//
//  TableViewScene.swift
//  XsAndOs
//
//  Created by Derik Flanary on 1/5/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation
import SpriteKit
import Parse 

class TableViewScene: XandOScene, UITableViewDataSource, UITableViewDelegate {
    
    var tableView = UITableView()
    var cancelButton = UIButton()
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        self.backgroundColor = backColor
        
        cancelButton.frame = CGRectMake(0, 20, view.frame.size.width, 30)
        cancelButton.setTitle("Cancel", forState: .Normal)
        cancelButton.titleLabel?.font = UIFont.boldSystemFontOfSize(18)
        cancelButton.setTitleColor(textColor, forState: .Normal)
        cancelButton.setTitleColor(UIColor(white: 0.7, alpha: 1.0), forState: .Highlighted)
        cancelButton.addTarget(self, action: "cancelPressed", forControlEvents: .TouchUpInside)
        self.view?.addSubview(cancelButton)
        
        tableView = UITableView(frame: CGRectMake(0, 50, self.view!.frame.size.width, self.view!.frame.size.height - 50), style: .Grouped)
        tableView.backgroundColor = backgroundColor
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view!.addSubview(tableView)
        tableView.reloadData()
    }

    func cancelPressed(){
        removeViews()
        let mainScene = GameScene(size: self.size)
        let transition = SKTransition.crossFadeWithDuration(0.75)
        mainScene.scaleMode = .AspectFill
        self.scene?.view?.presentScene(mainScene, transition: transition)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        
        return cell
    }
    
    override func removeViews(){
        tableView.removeFromSuperview()
        cancelButton.removeFromSuperview()
    }
}