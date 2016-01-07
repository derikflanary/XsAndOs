//
//  FriendListScene.swift
//  XsAndOs
//
//  Created by Derik Flanary on 1/2/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation
import SpriteKit
import Parse

class FriendListScene: TableViewScene{
    var friends = [[String:String]]()
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        FacebookController.Singleton.sharedInstance.fetchFriendsForUser(PFUser.currentUser()!) { (success: Bool,theFriends: [[String : String]]) -> Void in
            if success{
                dispatch_async(dispatch_get_main_queue(),{
                    self.friends = theFriends
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "Select a Friend to Play with"
        }else{
            return "Invite a Friend to Play"
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        if friends.count > 0{
            let friend = friends[indexPath.row] as Dictionary
            cell.textLabel?.text = friend["name"]
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0{
            let friend = friends[indexPath.row] as Dictionary
            let id = friend["id"]
            FacebookController.Singleton.sharedInstance.fetchFriendWithFacebookID(id!, completion: { (user) -> Void in
                let opponent = user as PFUser
                self.transitionToSetupScene(opponent)
            })
        }
        
    }
    
    func transitionToSetupScene(opponent: PFUser){
        let nextScene = MultiplayerSetupScene()
        nextScene.opponent = opponent
        let transition = SKTransition.crossFadeWithDuration(0.75)
        nextScene.scaleMode = .AspectFill
        self.scene?.view?.presentScene(nextScene, transition: transition)
        tableView.removeFromSuperview()
        cancelButton.removeFromSuperview()
    }
    
}