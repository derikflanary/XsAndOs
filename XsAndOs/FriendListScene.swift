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
import MessageUI

class FriendListScene: TableViewScene, MFMessageComposeViewControllerDelegate{
    var friends = [[String:String]]()
    var inviteFriends = [[String: String]]()
    let currentViewController = UIApplication.sharedApplication().keyWindow!.rootViewController!
    
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
            openMessageVC()
        }
    }
    
    //MARK: - TRANSITIONS
    private func openMessageVC(){
        let messageVC = MFMessageComposeViewController()
        messageVC.body = "Play X's and O's with me! https://itunes.apple.com/us/app/provo-ghost-tours-game-cycling/id1031990080?mt=8"
        messageVC.messageComposeDelegate = self
        currentViewController.presentViewController(messageVC, animated: true, completion: nil)
    }
    
    func transitionToSetupScene(opponent: PFUser){
        let nextScene = MultiplayerSetupScene()
        nextScene.opponent = opponent
        let transition = SKTransition.crossFadeWithDuration(0.75)
        nextScene.scaleMode = .AspectFill
        self.scene?.view?.presentScene(nextScene, transition: transition)
        removeViews()
    }
    
    //MARK: - MESSAGE CONTROLLER DELEGATE
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        switch (result.rawValue) {
        case MessageComposeResultCancelled.rawValue:
            print("Message was cancelled")
            currentViewController.dismissViewControllerAnimated(true, completion: nil)
        case MessageComposeResultFailed.rawValue:
            print("Message failed")
            currentViewController.dismissViewControllerAnimated(true, completion: nil)
        case MessageComposeResultSent.rawValue:
            print("Message was sent")
            currentViewController.dismissViewControllerAnimated(true, completion: nil)
        default:
            break;
        }
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