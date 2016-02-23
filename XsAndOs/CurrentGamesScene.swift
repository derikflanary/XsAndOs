//
//  CurrentGamesScene.swift
//  XsAndOs
//
//  Created by Derik Flanary on 1/5/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation
import SpriteKit
import Parse

class CurrentGamesScene: TableViewScene {
    
    var games = [PFObject]()
    var finishedGames = [PFObject]()
    var currentGames = [PFObject]()
    
    override func didMoveToView(view: SKView) {
        
        checkCurrentGames()
        
        PFInstallation.currentInstallation().badge = 0
        super.didMoveToView(view)
    }
    
    func checkCurrentGames(){
        XGameController.Singleton.sharedInstance.fetchGamesForUser(PFUser.currentUser()!) { (success, games) -> Void in
            guard success else{return}
            if games.count > 0{
                dispatch_async(dispatch_get_main_queue(),{
                    self.games = games
                    for game in games{
                        let finishedGame = game["finished"] as! Bool
                        if finishedGame{
                            self.finishedGames.append(game)
                        }else{
                            self.currentGames.append(game)
                        }
                    }
                    self.tableView.reloadData()
                })
            }
        }
    }

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return currentGames.count
        }else{
            return finishedGames.count
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "Current Games"
        }else{
            return "Finished Games"
        }
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView,
        forSection section: Int) {
            let header = view as! UITableViewHeaderFooterView
            header.textLabel?.font = UIFont(name: boldFontName, size: 18)
            header.textLabel?.textColor = textColor
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        cell.contentView.backgroundColor = UIColor.clearColor()
        
        let whiteRoundedView : UIView = UIView(frame: CGRectMake(0, 10, self.tableView.frame.size.width, 100))
        
        whiteRoundedView.layer.backgroundColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), [1.0, 1.0, 1.0, 1.0])
        whiteRoundedView.layer.masksToBounds = false
        whiteRoundedView.layer.cornerRadius = 10.0
        whiteRoundedView.layer.shadowOffset = CGSizeMake(-1, 1)
        whiteRoundedView.layer.shadowOpacity = 0.2
        
        cell.contentView.addSubview(whiteRoundedView)
        cell.contentView.sendSubviewToBack(whiteRoundedView)
        
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("GameCell") as! GameTableViewCell
        
        cell.layer.cornerRadius = 10
        cell.clipsToBounds = true
        cell.backgroundColor = UIColor.clearColor()
        
        var game = games[indexPath.row]
        if games.count > 0{
            if indexPath.section == 0{
                game = currentGames[indexPath.row] as PFObject
            }else{
                game = finishedGames[indexPath.row] as PFObject
            }
            
            let xUser = game["xTeam"] as! PFUser
            let name = xUser["name"] as! String
            let oUser = game["oTeam"] as! PFUser
            let oName = oUser["name"] as! String
            let xTurn = game["xTurn"] as! Bool
            let currentUser = PFUser.currentUser()
            let myName = currentUser!["name"] as! String
            var usersTurn = false
            if name == myName && xTurn || oName == myName && !xTurn{
                usersTurn = true
            }
            
            cell.xLabel.text = "X:\(name)"
            cell.oLabel.text = "O:\(oName)"
            cell.sizeLabel.text = "\(game["rows"])x\(game["rows"])"
            cell.dateLabel.text = daysBetweenDate(game.createdAt! as NSDate, endDate: NSDate())
            
            if usersTurn{
                cell.addTurnLabel()
            }
            cell.animateTurnView()
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var game = games[indexPath.row] as PFObject
        if indexPath.section == 0{
            game = currentGames[indexPath.row] as PFObject
        }else{
            game = finishedGames[indexPath.row] as PFObject
        }
        let dim = game["dim"] as? Int
        let rows = game["rows"] as? Int
        transitionToBoardScene(dim!, rows: rows!, game: game)
        removeViews()
    }

    func transitionToBoardScene(dim : Int, rows : Int, game: PFObject){
        let xUser = game["xTeam"] as! PFUser
        var userTeam = Board.UserTeam.O
        if xUser.objectId == PFUser.currentUser(){
            userTeam = Board.UserTeam.X
        }
        var secondScene = MultiplayerBoard(size: self.view!.frame.size, theDim: dim, theRows: rows, userTeam: userTeam, aiGame: false)
        secondScene = BoardSetupController().updateNextSceneWithGame(game, secondScene: secondScene)
        let transition = SKTransition.crossFadeWithDuration(1)
        self.scene!.view?.presentScene(secondScene, transition: transition)
    }
    
    func daysBetweenDate(startDate: NSDate, endDate: NSDate) -> String
    {
        let calendar = NSCalendar.currentCalendar()
        
        let components = calendar.components([.Day, .Hour], fromDate: startDate, toDate: endDate, options: [])
        let days = components.day
        let hours = components.hour

        let timeSince : String?
        if days == 1 {
            timeSince = "\(days) day ago"
        }else if days > 1{
            timeSince = "\(days) days ago"
        }else if hours > 1{
            timeSince = "\(hours) hours ago"
        }else if hours == 1{
            timeSince = "\(hours) hour ago"
        }else{
            timeSince = "less than an hour ago"
        }
        return timeSince!

    }
}
