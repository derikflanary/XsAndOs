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

        func createNewGame(xTeam: PFUser, oTeam: PFUser, rows: Int, dim: Int, completion: (Bool) -> Void){
            let newGame = PFObject(className: "XGame")
            newGame["rows"] = rows
            newGame["dim"] = dim
            newGame["xTeam"] = xTeam
            newGame["oTeam"] = oTeam
            newGame.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                if success{
                    completion(true)
                }else{
                    completion(false)
                }
            }
        }
        
        func fetchGamesForUser(user: PFUser, completion: (Bool, [PFObject]) -> Void){
            let query = PFQuery(className: "XGame")
            query.whereKey("xTeam", equalTo: user)
            let query2 = PFQuery(className: "XGame")
            query.whereKey("oTeam", equalTo: user)
            let orQuery = PFQuery.orQueryWithSubqueries([query, query2])
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
    }
}