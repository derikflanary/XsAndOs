//
//  XGameController.swift
//  XsAndOs
//
//  Created by Derik Flanary on 1/4/16.
//  Copyright © 2016 Derik Flanary. All rights reserved.
//

import Foundation
import ParseUI


class XGameController: NSObject {
    
    class Singleton  {
        
        static let sharedInstance = Singleton()

        func createNewGame(xTeam: PFUser, oTeam: PFUser, rows: Int, dim: Int, completion: (Bool, String) -> Void){
            let newGame = PFObject(className: "XGame")
            newGame["rows"] = rows
            newGame["dim"] = dim
            newGame["xTeam"] = xTeam
            newGame["oTeam"] = oTeam
            newGame["xLines"] = [LineShapeNode]()
            newGame["oLines"] = [LineShapeNode]()
            newGame["xTurn"] = true
            newGame["finished"] = false
            newGame.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                if success{
                    newGame.fetchInBackgroundWithBlock({ (game: PFObject?, error: NSError?) -> Void in
                        if error == nil{
                            completion(true, (game?.objectId)!)
                        }else{
                            completion(false, "")
                        }
                    })
                }else{
                    completion(false, "")
                }
            }
        }
        
        func fetchGamesForUser(user: PFUser, completion: (Bool, [PFObject]) -> Void){
            let query = PFQuery(className: "XGame")
            query.whereKey("xTeam", equalTo: user)
            let query2 = PFQuery(className: "XGame")
            query.whereKey("oTeam", equalTo: user)
            let orQuery = PFQuery.orQueryWithSubqueries([query, query2])
            orQuery.includeKey("xTeam")
            orQuery.includeKey("oTeam")
            orQuery.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
                if error == nil {
                    PFObject.fetchAllInBackground(results, block: { (objects: [AnyObject]?, error :NSError?) -> Void in
                        if error == nil{
                            let games = objects as! [PFObject]
                            completion(true, games)
                        }else{
                            completion(false, results!)
                        }
                    })
                }else{
                    completion(false, results!)
                }
            }
        }
        
        func updateGameOnParse(xTurn: Bool, xLines: [[[String: Int]]], oLines: [[[String: Int]]], id: String, completion: (Bool) -> Void){
            let query = PFQuery(className:"XGame")
            query.getObjectInBackgroundWithId(id) {(game: PFObject?, error: NSError?) -> Void in
                if error != nil {
                    print(error)
                } else if let game = game {
                    print(game)
                    game.addUniqueObjectsFromArray(xLines, forKey: "xLines")
                    game.addUniqueObjectsFromArray(oLines, forKey: "oLines")
                    game["xTurn"] = xTurn
                    game.saveInBackground()
                    completion(true)
                }
            }
        }
        
        func endGame(id: String){
            let query = PFQuery(className: "XGame")
            query.getObjectInBackgroundWithId(id) { (game: PFObject?, error: NSError?) -> Void in
                if error != nil {
                    print(error)
                } else if let game = game {
                    game["finished"] = true
                    game.saveInBackground()
                }
            }
        }
    }
}