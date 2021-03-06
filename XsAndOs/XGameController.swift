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
//MARK: - GAME CREATION
        func createNewGame(xTeam xTeam: PFUser, oTeam: PFUser, rows: Int, dim: Int, completion: (Bool, PFObject?, String, String, String) -> Void){
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
//MARK: - LINE CREATION
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
        
        
//MARK: - FETCH GAMES
        
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
                            self.deleteOldGames(results!)
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
        
//MARK: - DELETE
        func deleteOldGames(games: [PFObject]){
            for game in games{
                let finished = game["finished"] as! Bool
                let gameDate = game.createdAt
                let todayDate = NSDate()
                let timeInterval = todayDate.timeIntervalSinceDate(gameDate!)
                let hours = timeInterval / 3600
                if hours >= 168 && finished{
                    let xLines = game["xLines"] as! PFObject
                    let oLines = game["oLines"] as! PFObject
                    xLines.deleteEventually()
                    oLines.deleteEventually()
                    game.deleteEventually()
                }else if hours > 340{
                    let xLines = game["xLines"] as! PFObject
                    let oLines = game["oLines"] as! PFObject
                    xLines.deleteEventually()
                    oLines.deleteEventually()
                    game.deleteEventually()
                }
            }
        }
//MARK: - UPDATE
        func updateGameOnParse(xTurn: Bool, newLine: [[String: Int]], oldLines: [[[String:Int]]], gameId: String, xId: String, oId: String, lastMove:[[String:Int]], completion: (Bool) -> Void){
            let query = PFQuery(className:"XGame")
            query.getObjectInBackgroundWithId(gameId) {(game: PFObject?, error: NSError?) -> Void in
                if error != nil {
                    print(error)
                    completion(false)
                } else if let game = game {
                    if !xTurn{
                        self.updateLines(newLine, oldLines: oldLines, id: xId, type: "X", completion: { (success: Bool) -> Void in
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
                        self.updateLines(newLine, oldLines: oldLines, id: oId, type: "O", completion: { (success: Bool) -> Void in
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
        
        func updateLines(newLine: [[String:Int]], oldLines: [[[String:Int]]], id: String, type: String, completion: (Bool) -> Void){
            var query = PFQuery(className: "XLines")
            if type == "O"{
                query = PFQuery(className: "OLines")
            }
            query.getObjectInBackgroundWithId(id) { (lines: PFObject?, error: NSError?) -> Void in
                if error != nil{
                    print(error)
                    completion(false)
                }else if let lines = lines{
                    lines.addUniqueObject(newLine, forKey: "lines")
                    lines.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                        if success{
                            if oldLines.count > 0{
                                lines.removeObjectsInArray(oldLines, forKey: "lines")
                                lines.saveInBackgroundWithBlock({ (success, error) -> Void in
                                    if success{
                                        completion(success)
                                    }else{
                                        print(error)
                                        completion(success)
                                    }
                                })
                            }else{
                                completion(success)
                            }
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
//MARK: - DATE FUNCTIONS
        func dayAsString() -> String{
            let date = NSDate()
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd" //format style. Browse online to get a format that fits your needs.
            let dateString = dateFormatter.stringFromDate(date)
            return dateString
        }
        
        func daysBetweenDate(startDate: NSDate, endDate: NSDate) -> Int
        {
            let calendar = NSCalendar.currentCalendar()
            
            let components = calendar.components([.Day], fromDate: startDate, toDate: endDate, options: [])
            
            return components.day
        }
    }
}