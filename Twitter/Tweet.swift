//
//  Tweet.swift
//  Twitter
//
//  Created by Tran Khanh Trung on 10/29/16.
//  Copyright © 2016 TRUNG. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    
    var id_str: String?
    var text: String?
    
    var created_at: Date?
    var user: String?
    var retweet_count: Int = 0
    var retweeted: Bool = false
    var retweeted_status: Tweet?
    var favorite_count: Int = 0
    var favorited: Bool = false
    
    
    init(dictionary: NSDictionary) {
        id_str = dictionary["id_str"] as? String
        text = dictionary["text"] as? String
        
        let created_at_String = dictionary["created_at"] as? String
        if let created_at_String = created_at_String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
            created_at = dateFormatter.date(from: created_at_String)
        }
        
        user = dictionary["user"] as? String
        retweet_count = (dictionary["retweet_count"] as? Int) ?? 0
        retweeted = (dictionary["retweeted"] as? Bool) ?? false
        retweeted_status = dictionary["retweeted_status"] as? Tweet
        favorite_count = (dictionary["favorite_count"] as? Int) ?? 0
        favorited = (dictionary["favorited"] as? Bool) ?? false
    }
    
    class func tweetsWithArray(dictionaryArr: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        
        for dictItem in dictionaryArr{
            let tweet = Tweet(dictionary: dictItem)
            tweets.append(tweet)
        }
        return tweets
    }
}
