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
                    
                    if user.isNew {
                    
                        let userDetails = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"])
                        userDetails.startWithCompletionHandler { (connection, result, error: NSError!) -> Void in
                            
                            if (error != nil) {
                                print("error \(error.localizedDescription) ")
                                return
                            }
                            
                            if (result != nil) {

                                let userName: String = result.valueForKey("name") as! String
                                user.setObject(userName, forKey: "name")
//                              user.setObject(userEmail!, forKey: "email")
                                user.saveInBackground()
                            }
                        }
                        
                        print("User signed up and logged in through Facebook!");
                        let request = FBSDKGraphRequest(graphPath:"/me/friends", parameters:["fields": "id, name, email"]);
                        
                        request.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
                            if error == nil {
//                                print("Friends are : \(result)")
                                let resultdict = result as! NSDictionary
                                let data : NSArray = resultdict.objectForKey("data") as! NSArray
                                user.setObject(data, forKey: "friends")
                                user.saveInBackground()
                                completion(true, data as! [[String : String]])
                            } else {
                                print("Error Getting Friends \(error)");
                            }
                        }
                    } else {
                        print("User logged in through Facebook!");
                        
                        
                        if let friends = user["friends"] as? [[String:String]]{
                            
                            print(friends)
                            completion(true, friends)
                        }
                        
                    }

                }
            }
        }
}