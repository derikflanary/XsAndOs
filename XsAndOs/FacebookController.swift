//
//  FacebookController.swift
//  XsAndOs
//
//  Created by Derik Flanary on 12/28/15.
//  Copyright © 2015 Derik Flanary. All rights reserved.
//

import Foundation
import ParseFacebookUtilsV4

struct Friend {
    let name : String
    let id : String
}

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
//                                 print(result)

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
                                
                            } else {
                                print("Error Getting Friends \(error)");
                            }
                        }
                    } else {
                        print("User logged in through Facebook!");
                        
                        var friendList = [Friend]()
                        
                        if let friends = user["friends"] as? [[String:String]]{
                            for dict in friends{
                                let friend = Friend(name: dict["name"]!, id: dict["id"]!)
                                friendList.append(friend)
                            }
                            print(friends)
                            completion(true, friends)
                        }
                        
                        
                        //                        let request = FBSDKGraphRequest(graphPath:"/me/friends", parameters: ["fields": "id, name, email"]);
//
//                        request.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
//                            if error == nil {
//                                print("Friends are : \(result)")
//                            } else {
//                                print("Error Getting Friends \(error)");
//                            }
//                        }
                        
                    }

                }
            }
        }
}