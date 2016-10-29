//
//  TwitterClient.swift
//  Twitter
//
//  Created by Tran Khanh Trung on 10/29/16.
//  Copyright © 2016 TRUNG. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class TwitterClient: BDBOAuth1SessionManager {
    
    static let sharedInstance = TwitterClient(
        baseURL: NSURL(string: "https://api.twitter.com/") as URL!,
        consumerKey: "pMEdajjkOcc9sRphXlWrHUofr",
        consumerSecret: "ge7Q2aBBgcuiQmQLPPJmwnwIbIRNF0SBMuwSlQEBXqWLzM3D9M")!
    
    var loginSuccess: (() -> ())?
    var loginFailure: ((Error) -> ())?
    
    //MARK: - REQUEST TOKEN
    func login(success: @escaping () -> (), failure: @escaping (Error) -> ()){
        loginSuccess = success
        loginFailure = failure
        
        deauthorize()
        fetchRequestToken(withPath: "oauth/request_token", method: "POST",
                          callbackURL: URL(string: "TheSwiftBird://oath") as URL!, scope: nil,
                          success: { (response: BDBOAuth1Credential?) in
                            print("Request token >\((response?.token)!)<")
                            let authURL = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\((response?.token)!)")
                            UIApplication.shared.open(authURL!, options: [:]) { (response) in
                                //
                            }
            },
                          failure: { (error: Error?) in
                            print("\(error?.localizedDescription)")
                            self.loginFailure?(error!)
        })
    }
    
    //MARK: - ACCESS TOKEN
    func handleUrl(url: URL){
        let requestToken = BDBOAuth1Credential.init(queryString: url.query)
        fetchAccessToken(withPath: "oauth/access_token", method: "POST",
                         requestToken: requestToken,
                         success: { (response: BDBOAuth1Credential?) in
                            print("Access token >\((response?.token)!)<")
                            
                            self.currentUser(success: { (user:User) in
                                
                                User.currentUser = user
                                self.loginSuccess?()
                                },
                                             failure: { (error:Error) in
                                                self.loginFailure?(error)
                            })
            },
                         failure: { (error: Error?) in
                            print("\(error?.localizedDescription)")
                            self.loginFailure?(error!)
        })
    }
    
    //MARK: - LOGOUT
    func logout(){
        User.currentUser = nil
        deauthorize()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: User.userDidLogoutNotification), object: nil)
    }
    
    //MARK: - VERIFY CREDENTIALS
    func currentUser(success: @escaping (User) -> (), failure: @escaping (Error) -> ()){
        get("1.1/account/verify_credentials.json",
            parameters: nil, progress: nil,
            success: { (nil, verifyResponse) in
                let userDict = verifyResponse as! NSDictionary
                let user = User(dictionary: userDict)
                
                success(user)
                
                print(user.id_str)
                print(user.name)
                print(user.screenName)
                print(user.profile_imageUrl_https)
                
            },
            failure: { (nil, error: Error) in
                failure(error)
                print("\(error.localizedDescription)")
        })
    }
    
    //MARK: - HOME TIMELINE
    func homeTimeline(success: @escaping  ([Tweet]) -> (), failure: @escaping (Error) -> ()){
        get("1.1/statuses/home_timeline.json",
            parameters: nil, progress: nil,
            success: { (nil, verifyResponse) in
                
                let dictArr = verifyResponse as! [NSDictionary]
                let tweets = Tweet.tweetsWithArray(dictionaryArr: dictArr)
                success(tweets)
                
            },
            failure: { (nil, error: Error) in
                failure(error)
        })
    }
}
