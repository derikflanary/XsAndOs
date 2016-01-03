//
//  FriendsListViewController.swift
//  XsAndOs
//
//  Created by Derik Flanary on 12/29/15.
//  Copyright © 2015 Derik Flanary. All rights reserved.
//

import Foundation

class FriendsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var friends = [[String:String]]()
    let tableView = UITableView()
    
    override func viewDidLoad() {
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelPressed")
        navigationItem.leftBarButtonItem = cancelButton
        
        tableView.frame = self.view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(tableView)
        
        tableView.reloadData()
        print(friends)
    }
    
    func cancelPressed(){
        let gVC = GameViewController()
        self.view?.window?.rootViewController? = gVC
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        if friends.count > 0{
            let friend = friends[indexPath.row] as Dictionary
            cell.textLabel?.text = friend["name"]
            print(friend["name"])
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
}