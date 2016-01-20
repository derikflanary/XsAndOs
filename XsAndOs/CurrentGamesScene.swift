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
        PFInstallation.currentInstallation().badge = 0
        for game in games{
            let finishedGame = game["finished"] as! Bool
            if finishedGame{
                finishedGames.append(game)
            }else{
                currentGames.append(game)
            }
        }
        super.didMoveToView(view)
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
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell! = self.tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        if (cell != nil)
        {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle,
                reuseIdentifier: "cell")
        }
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
            cell.textLabel?.textColor = backgroundColor
            cell.detailTextLabel?.textColor = flint
            if usersTurn{
                cell.textLabel?.textColor = oColor
            }
            
            let finishedGame = game["finished"] as! Bool
            let text = "X:\(name)  |  O:\(oName)"
            if finishedGame{
                cell.textLabel?.textColor = xColor
            }
            cell.textLabel?.text = text
            cell!.detailTextLabel?.text = "\(game["startDate"])   \(game["rows"])x\(game["rows"])"
            cell.contentView.backgroundColor = textColor

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
        var secondScene = MultiplayerBoard(size: self.view!.frame.size, theDim: dim, theRows: rows)
        secondScene = BoardSetupController().updateNextSceneWithGame(game, secondScene: secondScene)
        let transition = SKTransition.crossFadeWithDuration(1)
        self.scene!.view?.presentScene(secondScene, transition: transition)
    }
}
