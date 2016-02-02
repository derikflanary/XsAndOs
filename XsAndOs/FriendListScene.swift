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

class FriendListScene: TableViewScene, FBSDKAppInviteDialogDelegate{
    var friends = [[String:String]]()
    var inviteFriends = [[String: String]]()
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        guard let currentUser = PFUser.currentUser() else{return}
        FacebookController.Singleton.sharedInstance.fetchFriendsForUser(currentUser) { (success: Bool, friends: [[String:String]], invitables: [[String:String]]) -> Void in
            if success{
                dispatch_async(dispatch_get_main_queue(),{
                    self.friends = friends
                    self.inviteFriends = invitables
                    var vNames = self.stringArrayFromDictionary(invitables, key: "name")
                    let fNames = self.stringArrayFromDictionary(friends, key: "name")
                    
                    for name in fNames{
                        if let x = vNames.indexOf(name){
                            vNames.removeAtIndex(x)
                            self.inviteFriends.removeAtIndex(x)
                        }
                    }
                    print(self.inviteFriends)
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    func stringArrayFromDictionary(characters: [[String:String]], key: String) -> [String] {
        return characters.map { character in
            character[key] ?? ""
        }
    }

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return friends.count
        }else{
            return 1
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
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
        if indexPath.section == 0{
            if friends.count > 0{
                let friend = friends[indexPath.row] as Dictionary
                cell.textLabel?.text = friend["name"]
            }

        }else{
            cell.textLabel?.text = "Invite Friends To Play!"
//            if inviteFriends.count > 0{
//                let friend = inviteFriends[indexPath.row] as Dictionary
//                cell.textLabel?.text = friend["name"]
//            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0{
            let friend = friends[indexPath.row] as Dictionary
            guard let id = friend["id"] else {return}
            FacebookController.Singleton.sharedInstance.fetchFriendWithFacebookID(id, completion: { (user) -> Void in
                let opponent = user as PFUser
                self.transitionToSetupScene(opponent)
            })
        }else{
            let content = FBSDKAppInviteContent()
            content.appLinkURL = NSURL(string: "https://itunes.apple.com/us/app/provo-ghost-tours-game-cycling/id1031990080?mt=8")
            FBSDKAppInviteDialog.showFromViewController(self.view?.window?.rootViewController, withContent: content, delegate: self)
        }
        
    }
    
    func transitionToSetupScene(opponent: PFUser){
        let nextScene = MultiplayerSetupScene()
        nextScene.opponent = opponent
        let transition = SKTransition.crossFadeWithDuration(0.75)
        nextScene.scaleMode = .AspectFill
        self.scene?.view?.presentScene(nextScene, transition: transition)
        removeViews()
    }
    
    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        print("invite did complete")
    }
    
    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: NSError!) {
        print(error)
    }
    
}

extension Array where Element: Equatable {
    mutating func removeObject(object: Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
    
    mutating func removeObjectsInArray(array: [Element]) {
        for object in array {
            self.removeObject(object)
        }
    }
}