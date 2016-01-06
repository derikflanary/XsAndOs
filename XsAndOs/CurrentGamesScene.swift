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
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Current Games"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        if games.count > 0{
            let game = games[indexPath.row] as PFObject
            cell.textLabel?.text = "\(game["rows"])"
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let game = games[indexPath.row] as PFObject
        print(game)
        let dim = game["dim"] as? Int
        let rows = game["rows"] as? Int
        transitionToBoardScene(dim!, rows: rows!, game: game)
    }

    private func transitionToBoardScene(dim : Int, rows : Int, game: PFObject){
        tableView.removeFromSuperview()
        cancelButton.removeFromSuperview()
        let secondScene = MultiplayerBoard(size: self.view!.frame.size, theDim: dim, theRows: rows)
        secondScene.xUser = game["xTeam"] as! PFUser
        secondScene.oUser = game["oTeam"] as! PFUser
        secondScene.gameID = game.objectId!
        secondScene.xLinesParse = game.objectForKey("xLines") as! [[[String:Int]]]
        secondScene.oLinesParse = game.objectForKey("oLines") as! [[[String:Int]]]
        secondScene.xTurnLoad = game["xTurn"] as! Bool
        secondScene.gameFinished = game["finished"] as! Bool
        secondScene.scaleMode = SKSceneScaleMode.AspectFill
        let transition = SKTransition.crossFadeWithDuration(1)
        self.scene!.view?.presentScene(secondScene, transition: transition)
        
    }

}
