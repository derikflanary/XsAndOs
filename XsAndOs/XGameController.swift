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
    }
}