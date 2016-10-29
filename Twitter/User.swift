//
//  User.swift
//  Twitter
//
//  Created by Tran Khanh Trung on 10/28/16.
//  Copyright © 2016 TRUNG. All rights reserved.
//

import UIKit

class User: NSObject {
        
    static let userDidLogoutNotification = "UserDidLogout"
    
    var id_str: String?
    var name: String?
    var screenName: String?
    var user_description: String?
    var profile_imageUrl_https: URL?
    
    var dictionary: NSDictionary
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        
        id_str = dictionary["id_str"] as? String
        name = dictionary["name"] as? String
        screenName = dictionary["screen_name"] as? String
        user_description = dictionary["description"] as? String
        let imageUrl_String = dictionary["profile_image_url_https"] as? String
        if let imageUrl_String = imageUrl_String {
            profile_imageUrl_https = URL(string: imageUrl_String)
        }
    }
    
    static var _currentUser: User?
    class var currentUser: User? {
        get{
            if _currentUser == nil {
                if let userData = TwitterDefaults.UserData {
                    do {
                        let dictionary = try JSONSerialization.jsonObject(with: userData, options: []) as! NSDictionary
                        _currentUser = User(dictionary: dictionary)
                    } catch (_) { }
                }
            }
            return _currentUser
        }
        
        set(user){
            _currentUser = user
            if user != nil {
                let userData = try! JSONSerialization.data(withJSONObject: user!.dictionary, options: [])
                TwitterDefaults.UserData = userData
            } else {
                TwitterDefaults.UserData = nil
            }
        }
    }
}
