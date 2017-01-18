////
////  CurrentGamesScene.swift
////  XsAndOs
////
////  Created by Derik Flanary on 1/5/16.
////  Copyright © 2016 Derik Flanary. All rights reserved.
////
//
//import Foundation
//import SpriteKit
//import Parse
//
//class CurrentGamesScene: TableViewScene {
//    
//    var games = [PFObject]()
//    var finishedGames = [PFObject]()
//    var currentGames = [PFObject]()
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
//        
//        checkCurrentGames()
//        
//        PFInstallation.current().badge = 0
//
//    }
//    
//    func checkCurrentGames(){
//        guard PFUser.current() != nil else{return}
//        
//        XGameController.Singleton.sharedInstance.fetchGamesForUser(PFUser.currentUser()!) { (success, games) -> Void in
//
//            self.activityIndicator.stopAnimating()
//            self.activityIndicator.removeFromSuperview()
//            
//            guard success else{return}
//            
//            if games.count > 0{
//                dispatch_async(dispatch_get_main_queue(),{
//                    self.games = games
//                    for game in games{
//                        let finishedGame = game["finished"] as! Bool
//                        if finishedGame{
//                            self.finishedGames.append(game)
//                        }else{
//                            self.currentGames.append(game)
//                        }
//                    }
//                    self.animateTable()
//                })
//            }
//        }
//    }
//
//    
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if section == 0{
//            return currentGames.count
//        }else{
//            return finishedGames.count
//        }
//    }
//    
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 2
//    }
//    
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if section == 0{
//            return "Current Games"
//        }else{
//            return "Finished Games"
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView,
//        forSection section: Int) {
//            let header = view as! UITableViewHeaderFooterView
//            header.textLabel?.font = UIFont(name: boldFontName, size: 18)
//            header.textLabel?.textColor = textColor
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
//        return 100
//    }
//    
//    func tableView(_ tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: IndexPath) {
//        
//        cell.contentView.backgroundColor = UIColor.clear
//        
//        let whiteRoundedView : UIView = UIView(frame: CGRect(x: 0, y: 10, width: self.tableView.frame.size.width, height: 100))
//        
//        whiteRoundedView.layer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 1.0, 1.0])
//        whiteRoundedView.layer.masksToBounds = false
//        whiteRoundedView.layer.cornerRadius = 10.0
//        whiteRoundedView.layer.shadowOffset = CGSize(width: -1, height: 1)
//        whiteRoundedView.layer.shadowOpacity = 0.2
//        
//        cell.contentView.addSubview(whiteRoundedView)
//        cell.contentView.sendSubview(toBack: whiteRoundedView)
//        
//    }
//
//    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = self.tableView.dequeueReusableCell(withIdentifier: "GameCell") as! GameTableViewCell
//        
//        cell.layer.cornerRadius = 10
//        cell.clipsToBounds = true
//        cell.backgroundColor = UIColor.clear
//        
//        var game = games[indexPath.row]
//        if games.count > 0{
//            if indexPath.section == 0{
//                game = currentGames[indexPath.row] as PFObject
//            }else{
//                game = finishedGames[indexPath.row] as PFObject
//            }
//            
//            let xUser = game["xTeam"] as! PFUser
//            let name = xUser["name"] as! String
//            let oUser = game["oTeam"] as! PFUser
//            let oName = oUser["name"] as! String
//            let xTurn = game["xTurn"] as! Bool
//            let currentUser = PFUser.current()
//            let myName = currentUser!["name"] as! String
//            var usersTurn = false
//            if name == myName && xTurn || oName == myName && !xTurn{
//                usersTurn = true
//            }
//            
//            cell.xLabel.text = "X:\(name)"
//            cell.oLabel.text = "O:\(oName)"
//            cell.sizeLabel.text = "\(game["rows"])x\(game["rows"])"
//            cell.dateLabel.text = daysBetweenDate(game.createdAt! as Date, endDate: Date())
//            
//            if usersTurn && indexPath.section == 0{
//                cell.addTurnLabel()
//                cell.animateTurnView()
//            }
//        }
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
//        var game = games[indexPath.row] as PFObject
//        if indexPath.section == 0{
//            game = currentGames[indexPath.row] as PFObject
//        }else{
//            game = finishedGames[indexPath.row] as PFObject
//        }
//        let dim = game["dim"] as? Int
//        let rows = game["rows"] as? Int
//        transitionToBoardScene(dim!, rows: rows!, game: game)
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
//            let cell: GameTableViewCell = i as! GameTableViewCell
//            cell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
//        }
//        
//        var index = 0
//        
//        for a in cells {
//            let cell: GameTableViewCell = a as! GameTableViewCell
//            UIView.animate(withDuration: 1.5, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
//                cell.transform = CGAffineTransform(translationX: 0, y: 0);
//                }, completion: nil)
//            
//            index += 1
//        }
//    }
//
//    //MARK: - TRANSITIONS
//    func transitionToBoardScene(_ dim : Int, rows : Int, game: PFObject){
//        let xUser = game["xTeam"] as! PFUser
//        var userTeam = Board.UserTeam.O
//        if xUser.objectId == PFUser.current()?.objectId{
//            userTeam = Board.UserTeam.X
//        }
//        var secondScene = MultiplayerBoard(size: self.view!.frame.size, theDim: dim, theRows: rows, userTeam: userTeam, aiGame: false)
//        secondScene = BoardSetupController().updateNextSceneWithGame(game, secondScene: secondScene)
//        let transition = SKTransition.crossFade(withDuration: 1)
//        self.scene!.view?.presentScene(secondScene, transition: transition)
//    }
//    
//    //MARK: - DATE FUNCTIONS
//    func daysBetweenDate(_ startDate: Date, endDate: Date) -> String{
//        let calendar = Calendar.current
//        let components = (calendar as NSCalendar).components([.day, .hour], from: startDate, to: endDate, options: [])
//        let days = components.day
//        let hours = components.hour
//
//        let timeSince : String?
//        if days == 1 {
//            timeSince = "\(days) day ago"
//        }else if days! > 1{
//            timeSince = "\(days) days ago"
//        }else if hours! > 1{
//            timeSince = "\(hours) hours ago"
//        }else if hours == 1{
//            timeSince = "\(hours) hour ago"
//        }else{
//            timeSince = "less than an hour ago"
//        }
//        return timeSince!
//
//    }
//}
