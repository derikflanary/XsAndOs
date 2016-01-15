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

        func createNewGame(xTeam: PFUser, oTeam: PFUser, rows: Int, dim: Int, completion: (Bool, PFObject?, String, String, String) -> Void){
            let newGame = PFObject(className: "XGame")
            newGame["rows"] = rows
            newGame["dim"] = dim
            newGame["xTeam"] = xTeam
            newGame["oTeam"] = oTeam
            newGame["xTurn"] = true
            newGame["finished"] = false
            newGame["startDate"] = dayAsString()
            newGame["lastMove"] = []
            createXLines { (xSuccess: Bool, xLines: PFObject) -> Void in
                if xSuccess{
                    self.createOLines({ (oSuccess: Bool, oLines: PFObject) -> Void in
                        if oSuccess{
                            newGame["xLines"] = xLines
                            newGame["oLines"] = oLines
                            newGame.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                                if success{
                                    newGame.fetchInBackgroundWithBlock({ (game: PFObject?, error: NSError?) -> Void in
                                        if error == nil{
                                            completion(true,game, (game?.objectId)!, xLines.objectId!, oLines.objectId!)
                                        }else{
                                            completion(false, nil, "", "", "")
                                        }
                                    })
                                }else{
                                    completion(false, nil, "", "", "")
                                }
                            }

                        }
                    })
                }
            }
        }
        
        func createXLines(completion: (Bool, PFObject) -> Void){
            let xLines = PFObject(className: "XLines")
            xLines["lines"] = [[[String:Int]]]()
            xLines.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                xLines.fetchInBackgroundWithBlock({ (lines: PFObject?, error: NSError?) -> Void in
                    if error != nil{
                        print(error)
                        completion(false, xLines)
                    }else if let lines = lines {
                        completion(true, lines)
                    }

                })
            }
        }
        
        func createOLines(completion: (Bool, PFObject) -> Void){
            let oLines = PFObject(className: "OLines")
            oLines["lines"] = [[[String:Int]]]()
            oLines.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                oLines.fetchInBackgroundWithBlock({ (lines: PFObject?, error: NSError?) -> Void in
                    if error != nil{
                        print(error)
                        completion(false, oLines)
                    }else if let lines = lines {
                        completion(true, lines)
                    }
                    
                })
            }

        }
        
        func fetchGamesForUser(user: PFUser, completion: (Bool, [PFObject]) -> Void){
            let query = PFQuery(className: "XGame")
            query.whereKey("xTeam", equalTo: PFUser.currentUser()!)
            let query2 = PFQuery(className: "XGame")
            query2.whereKey("oTeam", equalTo: PFUser.currentUser()!)
            let orQuery = PFQuery.orQueryWithSubqueries([query, query2])
            orQuery.includeKey("xTeam")
            orQuery.includeKey("oTeam")
            orQuery.includeKey("xLines")
            orQuery.includeKey("oLines")
            orQuery.orderByDescending("createdAt")
            orQuery.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
                if error == nil {
                    PFObject.fetchAllIfNeededInBackground(results, block: { (objects: [AnyObject]?, error :NSError?) -> Void in
                        if error == nil{
                            let games = objects as! [PFObject]
                            completion(true, games)
                        }else{
                            completion(false, results!)
                        }
                    })
                }else{
                    completion(false, [])
                }
            }
        }
        
        func updateGameOnParse(xTurn: Bool, xLines: [[[String: Int]]], oLines: [[[String: Int]]], gameId: String, xId: String, oId: String, lastMove:[[String:Int]], completion: (Bool) -> Void){
            let query = PFQuery(className:"XGame")
            query.getObjectInBackgroundWithId(gameId) {(game: PFObject?, error: NSError?) -> Void in
                if error != nil {
                    print(error)
                    completion(false)
                } else if let game = game {
                    if !xTurn{
                        self.updateXlines(xLines, id: xId, completion: { (success: Bool) -> Void in
                            if success{
                                game["xTurn"] = xTurn
                                game["lastMove"] = lastMove
                                game.saveInBackground()
                                completion(true)
                            }else{
                                completion(false)
                            }
                        })
                    }else{
                        self.updateOlines(oLines, id: oId, completion: { (success: Bool) -> Void in
                            if success{
                                game["xTurn"] = xTurn
                                game["lastMove"] = lastMove
                                game.saveInBackground()
                                completion(true)
                            }else{
                                completion(false)
                            }
                        })
                    }
                }
            }
        }
        
        func updateXlines(xLines: [[[String: Int]]], id: String, completion: (Bool) -> Void){
            let query = PFQuery(className: "XLines")
            query.getObjectInBackgroundWithId(id) { (lines: PFObject?, error: NSError?) -> Void in
                if error != nil{
                    print(error)
                    completion(false)
                }else if let lines = lines{
                    lines["lines"] = [[[String: Int]]]()
                    lines.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                        if success{
                            lines["lines"] = xLines
                            lines.saveInBackgroundWithBlock({ (success, error) -> Void in
                                if success{
                                  completion(success)
                                }else{
                                    print(error)
                                    completion(success)
                                }
                            })
                        }else{
                            completion(false)
                        }
                    })
                }
            }
        
        }
        
        func updateOlines(oLines: [[[String: Int]]], id: String, completion: (Bool) -> Void){
            let query = PFQuery(className: "OLines")
            query.getObjectInBackgroundWithId(id) { (lines: PFObject?, error: NSError?) -> Void in
                if error != nil{
                    print(error)
                    completion(false)
                }else if let lines = lines{
                    lines["lines"] = [[[String: Int]]]()
                    lines.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                        if success{
                            lines["lines"] = oLines
                            lines.saveInBackgroundWithBlock({ (success, error) -> Void in
                                if success{
                                    completion(success)
                                }else{
                                    print(error)
                                    completion(success)
                                }

                            })
                        }else{
                            completion(false)
                        }
                    })
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
        
        func fetchGameForId(gameId: String, completion: (Bool, PFObject) -> Void){
            let query = PFQuery(className: "XGame")
            query.includeKey("xTeam")
            query.includeKey("oTeam")
            query.includeKey("xLines")
            query.includeKey("oLines")
            query.getObjectInBackgroundWithId(gameId) { (game: PFObject?,error: NSError?) -> Void in
                if error != nil {
                    print(error)
                    completion(false, game!)
                } else if let game = game {
                    completion(true, game)
                }

            }
        }
        
        func dayAsString() -> String{
            let date = NSDate()
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MMM d" //format style. Browse online to get a format that fits your needs.
            let dateString = dateFormatter.stringFromDate(date)
            return dateString
        }
    }
}