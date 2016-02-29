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
    var activityIndicator = DGActivityIndicatorView()
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        
        activityIndicator = DGActivityIndicatorView(type: DGActivityIndicatorAnimationType .BallZigZagDeflect, tintColor: textColor, size: 100)
        activityIndicator.frame = CGRectMake(view.frame.size.width/2 - 25, view.frame.size.height/2, 50.0, 50.0);
        activityIndicator.center = tableView.center
        self.tableView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        fetchData()
    }
    
    func fetchData(){
        guard let currentUser = PFUser.currentUser() else{return}
        FacebookController.Singleton.sharedInstance.fetchFriendsForUser(currentUser) { (success: Bool, friends: [[String:String]], invitables: [[String:String]]) -> Void in
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
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
                    self.animateTable()
                })
            }
        }
    }
    
    func stringArrayFromDictionary(characters: [[String:String]], key: String) -> [String] {
        return characters.map { character in
            character[key] ?? ""
        }
    }

    //MARK: - TABLEVIEW METHODS
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard friends.count > 0 else{return 0}
        if section == 0{
            return friends.count
        }else{
            return 1
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView,
        forSection section: Int) {
            let header = view as! UITableViewHeaderFooterView
            header.textLabel?.font = UIFont(name: boldFontName, size: 18)
            header.textLabel?.textColor = textColor
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "Select a Friend to Play with"
        }else{
            return "Invite a Friend to Play"
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        cell.contentView.backgroundColor = UIColor.clearColor()
        
        let whiteRoundedView : UIView = UIView(frame: CGRectMake(0, 10, self.tableView.frame.size.width, 80))
        
        whiteRoundedView.layer.backgroundColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), [1.0, 1.0, 1.0, 1.0])
        whiteRoundedView.layer.masksToBounds = false
        whiteRoundedView.layer.cornerRadius = 10.0
        whiteRoundedView.layer.shadowOffset = CGSizeMake(-1, 1)
        whiteRoundedView.layer.shadowOpacity = 0.2
        
        cell.contentView.addSubview(whiteRoundedView)
        cell.contentView.sendSubviewToBack(whiteRoundedView)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        
        cell.layer.cornerRadius = 10
        cell.clipsToBounds = true
        cell.textLabel?.font =  UIFont(name: boldFontName, size: 24)
        cell.textLabel?.textColor = flint
        cell.backgroundColor = UIColor.clearColor()
        
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
        messageVC.body = "Play X's and O's with me! https://launchkit.io/websites/TuUEQiL_mig/"
        messageVC.messageComposeDelegate = self
        currentViewController.presentViewController(messageVC, animated: true, completion: nil)
    }
    
    func transitionToSetupScene(opponent: PFUser){
        let nextScene = SingleSetupScene(size: self.size, type: SingleSetupScene.GameType.Online)
        nextScene.opponent = opponent
        let transition = SKTransition.crossFadeWithDuration(0.75)
        nextScene.scaleMode = .AspectFill
        self.scene?.view?.presentScene(nextScene, transition: transition)
        removeViews()
    }
    
    //MARK: - TABLEVIEW ANIMATION
    func animateTable() {
        tableView.reloadData()
        
        let cells = tableView.visibleCells
        let tableHeight: CGFloat = tableView.bounds.size.height
        
        for i in cells {
            let cell: UITableViewCell = i as UITableViewCell
            cell.transform = CGAffineTransformMakeTranslation(0, tableHeight)
        }
        
        var index = 0
        
        for a in cells {
            let cell: UITableViewCell = a as UITableViewCell
            UIView.animateWithDuration(1.5, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseOut, animations: {
                cell.transform = CGAffineTransformMakeTranslation(0, 0);
                }, completion: nil)
            
            index += 1
        }
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