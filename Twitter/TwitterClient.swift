//
//  TwitterClient.swift
//  Twitter
//
//  Created by Tran Khanh Trung on 10/29/16.
//  Copyright © 2016 TRUNG. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

let BASE_URL = "https://api.twitter.com/"
let CONSUMER_KEY = "NT6Ws92ktDmqyoQZyTvAHJ1Pb"
let CONSUMER_SECRET = "8zfScWQC9ZCIl6ejDifVTKhoNxBeFx7BDyVG5bipfg8sf44iKE"

//let CONSUMER_KEY = "JxUiG0fZyXliskmGJZYLjZcc4"
//let CONSUMER_SECRET = "2rW7IMZQ9Iz73JTwm800PGoaRHTPa3Vz59nDRXx2I1NIEaiipo"


class TwitterClient: BDBOAuth1SessionManager {
    
    static let sharedInstance = TwitterClient(
        baseURL: NSURL(string: BASE_URL) as URL!,
        consumerKey: CONSUMER_KEY,
        consumerSecret: CONSUMER_SECRET)!
    
    var loginSuccess: (() -> ())?
    var loginFailure: ((Error) -> ())?
    
    //MARK: - CURRENT ACCESS TOKEN
    static var _currentAccessToken: BDBOAuth1Credential?
    class var currentAccessToken: BDBOAuth1Credential? {
        get{
            if _currentAccessToken == nil {
                if let accessTokenData = TwitterDefaults.AccessTokenData {
                    if let accessToken = NSKeyedUnarchiver.unarchiveObject(with: accessTokenData) as? BDBOAuth1Credential {
                        _currentAccessToken = accessToken
                    }
                }
            }
            return _currentAccessToken
        }
        
        set(accessToken){
            _currentAccessToken = accessToken
            if accessToken != nil {
                TwitterDefaults.AccessTokenData = NSKeyedArchiver.archivedData(withRootObject: accessToken!)
            } else {
                TwitterDefaults.AccessTokenData = nil
            }
        }
    }
    
    
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
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(authURL!, options: [:]) { (response) in
                                    //
                                }
                            } else {
                                // Fallback on earlier versions
                                
                                let canOpen = UIApplication.shared.openURL(authURL!)
                                print(canOpen.description)
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
                                TwitterClient.currentAccessToken = response
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
        TwitterClient.currentAccessToken = nil
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
    func homeTimeline(max_id: Int64, success: @escaping  ([Tweet]) -> (), failure: @escaping (Error) -> ()){
        var  params: [String : AnyObject]?
        if max_id != 0 {
            params = ["max_id":(max_id as AnyObject?)!]
        } else {
            params = nil
        }
        
        get("1.1/statuses/home_timeline.json",
            parameters: params, progress: nil,
            success: { (nil, response) in
                
                let dictArr = response as! [NSDictionary]
                let tweets = Tweet.tweetsWithArray(dictionaryArr: dictArr)
                success(tweets)
                
            },
            failure: { (nil, error: Error) in
                failure(error)
        })
    }
    
    func homeTimelineWith(params: NSDictionary?,
                          completion: @escaping (_ success: [Tweet]?, _ failure: Error?) -> ()) {
        get("1.1/statuses/home_timeline.json", parameters: params, progress: nil,
            success: { (urlSessionDataTask, response) in
                let tweets = Tweet.tweetsWithArray(dictionaryArr: response as! [NSDictionary])
                completion(tweets, nil)
            },
            failure: { (urlSessionDataTask, error: Error?) in
                completion(nil, error)
        })
    }
    
    //MARK: - statuses/retweet/:id
    func retweet(id_Int: Int64, success: @escaping  (Tweet) -> (), failure: @escaping (Error) -> ()){
        post("1.1/statuses/retweet/\(id_Int).json",
            parameters: nil, progress: nil,
            success: { (nil, response) in
                
                let dictArr = response as! NSDictionary
                let tweet = Tweet(dictionary: dictArr)
                success(tweet)
            },
            failure: { (nil, error: Error) in
                failure(error)
        })
    }
    
    //MARK: - statuses/unretweet/:id
    func unretweet(id_Int: Int64, success: @escaping  (Tweet) -> (), failure: @escaping (Error) -> ()){
        post("1.1/statuses/unretweet/\(id_Int).json",
            parameters: nil, progress: nil,
            success: { (nil, response) in
                
                let dictArr = response as! NSDictionary
                let tweet = Tweet(dictionary: dictArr)
                success(tweet)
            },
            failure: { (nil, error: Error) in
                failure(error)
        })
    }
    
    //MARK: - favorites/create
    func createFavorite(id_Int: Int64, success: @escaping  (Tweet) -> (), failure: @escaping (Error) -> ()){
        
        let params: [String : AnyObject] = ["id":(id_Int as AnyObject?)!]
        post("1.1/favorites/create.json",
             parameters: params, progress: nil,
             success: { (nil, response) in
                
                let dictArr = response as! NSDictionary
                let tweet = Tweet(dictionary: dictArr)
                success(tweet)
            },
             failure: { (nil, error: Error) in
                failure(error)
        })
    }
    
    //MARK: - favorites/destroy
    func destroyFavorite(id_Int: Int64, success: @escaping  (Tweet) -> (), failure: @escaping (Error) -> ()){
        
        let params: [String : AnyObject] = ["id":(id_Int as AnyObject?)!]
        post("1.1/favorites/destroy.json",
             parameters: params, progress: nil,
             success: { (nil, response) in
                
                let dictArr = response as! NSDictionary
                let tweet = Tweet(dictionary: dictArr)
                success(tweet)
            },
             failure: { (nil, error: Error) in
                failure(error)
        })
    }
    
    //MARK: - statuses/lookup
    func lookupStatuses(id_Int: Int64, success: @escaping  ([Tweet]) -> (), failure: @escaping (Error) -> ()){
        let params: [String : AnyObject] = ["id":(id_Int as AnyObject?)!]
        get("1.1/statuses/lookup.json",
            parameters: params, progress: nil,
            success: { (nil, response) in
                
                let dictArr = response as! [NSDictionary]
                let tweets = Tweet.tweetsWithArray(dictionaryArr: dictArr)
                success(tweets)
                
            },
            failure: { (nil, error: Error) in
                failure(error)
        })
    }
    
    //MARK: - statuses/update
    func updateStatuses(status: String,
                        completion: @escaping (_ success: Tweet?, _ failure: Error?) -> ()) {
        let params: [String : AnyObject] = ["status":(status as AnyObject?)!]
        post("1.1/statuses/update.json", parameters: params, progress: nil,
             success: { (urlSessionDataTask, response) in
                let tweet = Tweet(dictionary: response as! NSDictionary)
                completion(tweet, nil)
            },
             failure: { (urlSessionDataTask, error: Error?) in
                completion(nil, error)
        })
    }
    
    //MARK: - statuses/show/:id
    func showStatusByID(params: NSDictionary?,
                        completion: @escaping (_ success: Tweet?, _ failure: Error?) -> ()) {
        get("1.1/statuses/show.json", parameters: params, progress: nil,
            success: { (urlSessionDataTask, response) in
                let tweet = Tweet(dictionary: response as! NSDictionary)
                completion(tweet, nil)
            },
            failure: { (urlSessionDataTask, error: Error?) in
                completion(nil, error)
        })
    }
}
