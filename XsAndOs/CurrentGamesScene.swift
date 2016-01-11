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
            let name = xUser["name"]
            let oUser = game["oTeam"] as! PFUser
            let oName = oUser["name"]
            let finishedGame = game["finished"] as! Bool
            var text = "X:\(name)  |  O:\(oName)"
            if finishedGame{
                text = text + " (finished)"
                cell.textLabel?.textColor = UIColor.redColor()
            }
            cell.textLabel?.text = text
            cell!.detailTextLabel?.text = "\(game["startDate"])   \(game["rows"])x\(game["rows"])"

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
        secondScene = updateNextSceneWithGame(game, secondScene: secondScene)
        let transition = SKTransition.crossFadeWithDuration(1)
        self.scene!.view?.presentScene(secondScene, transition: transition)
    }
    
    func updateNextSceneWithGame(game: PFObject, secondScene: MultiplayerBoard) -> (MultiplayerBoard){
        secondScene.xUser = game["xTeam"] as! PFUser
        secondScene.oUser = game["oTeam"] as! PFUser
        secondScene.gameID = game.objectId!
        let xLines = game.objectForKey("xLines") as! PFObject
        let oLines = game.objectForKey("oLines") as! PFObject
        secondScene.xLinesParse = xLines["lines"] as! [[[String:Int]]]
        secondScene.oLinesParse = oLines["lines"] as! [[[String:Int]]]
        secondScene.xTurnLoad = game["xTurn"] as! Bool
        secondScene.gameFinished = game["finished"] as! Bool
        secondScene.xObjId = xLines.objectId!
        secondScene.oObjId = oLines.objectId!
        secondScene.scaleMode = SKSceneScaleMode.AspectFill
        return secondScene
    }

}
