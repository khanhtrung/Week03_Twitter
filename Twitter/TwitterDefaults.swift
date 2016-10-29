//
//  TwitterDefaults.swift
//  Twitter
//
//  Created by Tran Khanh Trung on 10/29/16.
//  Copyright © 2016 TRUNG. All rights reserved.
//

import UIKit

let CURRENT_USER_DATA = "currentUserData"
let CURRENT_ACCESS_TOKEN_DATA = "currentAccessToken"

class TwitterDefaults: NSObject {
    
    //REMARK: - USER DATA
    static var _userData: Data?
    class var UserData: Data? {
        get {
            if let userData = UserDefaults.standard.object(forKey: CURRENT_USER_DATA) as? Data {
                _userData = userData
            }
            return _userData
        }
        set(userData) {
            if userData != nil {
                UserDefaults.standard.set(userData, forKey: CURRENT_USER_DATA)
            } else {
                UserDefaults.standard.removeObject(forKey: CURRENT_USER_DATA)
            }
            UserDefaults.standard.synchronize()
        }
    }
    
    //REMARK: - ACCESS TOKEN DATA
    static var _accessTokenData: Data?
    class var AccessTokenData: Data? {
        get {
            if let accessTokenData = UserDefaults.standard.object(forKey: CURRENT_ACCESS_TOKEN_DATA) as? Data {
                _accessTokenData = accessTokenData
            }
            return _accessTokenData
        }
        set (accessTokenData) {
            _accessTokenData = accessTokenData
            
            if accessTokenData != nil {
                UserDefaults.standard.set(accessTokenData, forKey: CURRENT_ACCESS_TOKEN_DATA)
            } else {
                UserDefaults.standard.removeObject(forKey: CURRENT_ACCESS_TOKEN_DATA)
            }
            UserDefaults.standard.synchronize()
        }
    }
}
