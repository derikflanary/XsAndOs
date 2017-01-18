////
////  FriendListScene.swift
////  XsAndOs
////
////  Created by Derik Flanary on 1/2/16.
////  Copyright © 2016 Derik Flanary. All rights reserved.
////
//
//import Foundation
//import SpriteKit
//import Parse
//import MessageUI
//
//class FriendListScene: TableViewScene, MFMessageComposeViewControllerDelegate{
//    var friends = [[String:String]]()
//    let currentViewController = UIApplication.shared.keyWindow!.rootViewController!
//    var activityIndicator = DGActivityIndicatorView()
//    
//    override func didMove(to view: SKView) {
//        super.didMove(to: view)
//        
//        activityIndicator = DGActivityIndicatorView(type: DGActivityIndicatorAnimationType .ballZigZagDeflect, tintColor: textColor, size: 100)
//        activityIndicator.frame = CGRect(x: view.frame.size.width/2 - 25, y: view.frame.size.height/2, width: 50.0, height: 50.0);
//        activityIndicator.center = tableView.center
//        self.tableView.addSubview(activityIndicator)
//        activityIndicator.startAnimating()
//        fetchData()
//    }
//    
//    func fetchData(){
//        guard let currentUser = PFUser.current() else{return}
//        FacebookController.Singleton.sharedInstance.fetchFriendsForUser(currentUser) { (success: Bool, friends: [[String:String]]) -> Void in
//            self.activityIndicator.stopAnimating()
//            self.activityIndicator.removeFromSuperview()
//            if success{
//                dispatch_async(dispatch_get_main_queue(),{
//                    self.friends = friends
//                    
//                    self.animateTable()
//                })
//            }
//        }
//    }
//    
//    func stringArrayFromDictionary(_ characters: [[String:String]], key: String) -> [String] {
//        return characters.map { character in
//            character[key] ?? ""
//        }
//    }
//
//    //MARK: - TABLEVIEW METHODS
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        guard friends.count > 0 else{return 0}
//        if section == 0{
//            return friends.count
//        }else{
//            return 1
//        }
//    }
//    
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 2
//    }
//    
//    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView,
//        forSection section: Int) {
//            let header = view as! UITableViewHeaderFooterView
//            header.textLabel?.font = UIFont(name: boldFontName, size: 18)
//            header.textLabel?.textColor = textColor
//    }
//
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if section == 0{
//            return "Select a Friend to Play with"
//        }else{
//            return "Invite a Friend to Play"
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
//        return 80
//    }
//    
//    func tableView(_ tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: IndexPath) {
//        
//        cell.contentView.backgroundColor = UIColor.clear
//        
//        let whiteRoundedView : UIView = UIView(frame: CGRect(x: 0, y: 10, width: self.tableView.frame.size.width, height: 80))
//        
//        whiteRoundedView.layer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 1.0, 1.0])
//        whiteRoundedView.layer.masksToBounds = false
//        whiteRoundedView.layer.cornerRadius = 10.0
//        whiteRoundedView.layer.shadowOffset = CGSize(width: -1, height: 1)
//        whiteRoundedView.layer.shadowOpacity = 0.2
//        
//        cell.contentView.addSubview(whiteRoundedView)
//        cell.contentView.sendSubview(toBack: whiteRoundedView)
//    }
//    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
//        
//        cell.layer.cornerRadius = 10
//        cell.clipsToBounds = true
//        cell.textLabel?.font =  UIFont(name: boldFontName, size: 24)
//        cell.textLabel?.textColor = flint
//        cell.backgroundColor = UIColor.clear
//        
//        if indexPath.section == 0{
//            if friends.count > 0{
//                let friend = friends[indexPath.row] as Dictionary
//                cell.textLabel?.text = friend["name"]
//            }
//
//        }else{
//            cell.textLabel?.text = "Invite Friends To Play!"
//        }
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
//        if indexPath.section == 0{
//            let friend = friends[indexPath.row] as Dictionary
//            guard let id = friend["id"] else {return}
//            FacebookController.Singleton.sharedInstance.fetchFriendWithFacebookID(id, completion: { (user) -> Void in
//                let opponent = user as PFUser
//                self.transitionToSetupScene(opponent)
//            })
//        }else{
//            openMessageVC()
//        }
//    }
//    
//    //MARK: - TRANSITIONS
//    fileprivate func openMessageVC(){
//        let messageVC = MFMessageComposeViewController()
//        messageVC.body = "Play X's and O's with me! https://itunes.apple.com/us/app/xs-os-2-player-strategy-game/id1068007420?mt=8"
//        messageVC.messageComposeDelegate = self
//        currentViewController.present(messageVC, animated: true, completion: nil)
//    }
//    
//    func transitionToSetupScene(_ opponent: PFUser){
//        let nextScene = SingleSetupScene(size: self.size, type: SingleSetupScene.GameType.online)
//        nextScene.opponent = opponent
//        let transition = SKTransition.crossFade(withDuration: 0.75)
//        nextScene.scaleMode = .aspectFill
//        self.scene?.view?.presentScene(nextScene, transition: transition)
//        removeViews()
//    }
//    
//    //MARK: - TABLEVIEW ANIMATION
//    func animateTable() {
//        tableView.reloadData()
//        
//        let cells = tableView.visibleCells
//        let tableHeight: CGFloat = tableView.bounds.size.height
//        
//        for i in cells {
//            let cell: UITableViewCell = i as UITableViewCell
//            cell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
//        }
//        
//        var index = 0
//        
//        for a in cells {
//            let cell: UITableViewCell = a as UITableViewCell
//            UIView.animate(withDuration: 1.5, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
//                cell.transform = CGAffineTransform(translationX: 0, y: 0);
//                }, completion: nil)
//            
//            index += 1
//        }
//    }
//    
//    //MARK: - MESSAGE CONTROLLER DELEGATE
//    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
//        switch (result.rawValue) {
//        case MessageComposeResultCancelled.rawValue:
//            print("Message was cancelled")
//            currentViewController.dismiss(animated: true, completion: nil)
//        case MessageComposeResultFailed.rawValue:
//            print("Message failed")
//            currentViewController.dismiss(animated: true, completion: nil)
//        case MessageComposeResultSent.rawValue:
//            print("Message was sent")
//            currentViewController.dismiss(animated: true, completion: nil)
//        default:
//            break;
//        }
//    }
//    
//}
//
//extension Array where Element: Equatable {
//    mutating func removeObject(_ object: Element) {
//        if let index = self.index(of: object) {
//            self.remove(at: index)
//        }
//    }
//    
//    mutating func removeObjectsInArray(_ array: [Element]) {
//        for object in array {
//            self.removeObject(object)
//        }
//    }
//}
