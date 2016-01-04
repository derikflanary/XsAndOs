//
//  FacebookController.swift
//  XsAndOs
//
//  Created by Derik Flanary on 12/28/15.
//  Copyright © 2015 Derik Flanary. All rights reserved.
//

import Foundation
import ParseFacebookUtilsV4

class FacebookController: NSObject {
    
        class Singleton  {
            
        static let sharedInstance = Singleton()

            func loginToFacebook(completion: (Bool, [[String:String]]) -> Void){

                PFFacebookUtils.logInInBackgroundWithReadPermissions(["public_profile", "user_friends", "user_birthday"]) {
                    (user: PFUser?, error: NSError?) -> Void in
                    guard let user = user else{
                        print("Uh oh. The user cancelled the Facebook login. \(error)")
                        completion(false, Array())
                        return
                    }
                    print("User logged in through Facebook!");
                    NSNotificationCenter.defaultCenter().postNotificationName("FacebookLoggedIn", object: nil)
                    if user.isNew {
                        self.fetchFacebookDetailsForUser(user, completion: { (success) -> Void in
                        })
                    }
                    
                    self.fetchFriendsForUser(user, completion: { (success, friends) -> Void in
                        guard success else{completion(false, friends) ; return}
                        completion(true, friends)
                    })
                }
            }
            
            func fetchFacebookDetailsForUser(user: PFUser, completion: (Bool) -> Void){
                let userDetails = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"])
                userDetails.startWithCompletionHandler { (connection, result, error: NSError!) -> Void in
                    
                    if (error != nil) {
                        print("error \(error.localizedDescription) ")
                        completion(false)
                    }
                    let userName: String = result.valueForKey("name") as! String
                    let id : String = result.valueForKey("id") as! String
                    user.setObject(id, forKey: "facebookID")
                    user.setObject(userName, forKey: "name")
                    user.saveInBackground()
                }
            }
            
            func fetchFriendsForUser(user : PFUser, completion: (Bool, [[String:String]]) -> Void){

                let request = FBSDKGraphRequest(graphPath:"/me/friends", parameters:["fields": "id, name, email"]);
                request.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
                    
                    if error == nil {
                        let resultdict = result as! NSDictionary
                        let data : NSArray = resultdict.objectForKey("data") as! NSArray
                        user.setObject(data, forKey: "friends")
                        user.saveInBackground()
                        completion(true, data as! [[String : String]])
                        
                    } else {
                        print("Error Getting Friends \(error)");
                        completion(false, result as! [[String : String]])
                    }
                }
            }
            
            
            func fetchFriendWithFacebookID(id : String, completion: (PFUser) -> Void){
                let query = PFUser.query()
                query!.whereKey("facebookID", equalTo: id)
                query?.getFirstObjectInBackgroundWithBlock({ (user : PFObject?,error : NSError?) -> Void in
                    
                    let friendUser = user as! PFUser
                    if (error == nil){
                        completion(friendUser)
                    }
                    
                })
                
            }
            
        }
}

    