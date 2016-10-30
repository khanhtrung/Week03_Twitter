//
//  HomeTweetCell.swift
//  Twitter
//
//  Created by Tran Khanh Trung on 10/30/16.
//  Copyright © 2016 TRUNG. All rights reserved.
//

import UIKit
import NSDate_TimeAgo


@objc protocol HomeTweetCellDelegate {
    @objc optional func retweet(homeTweetCell: HomeTweetCell, didChangeValue value: Bool)
    
    @objc optional func favorite(homeTweetCell: HomeTweetCell, didChangeValue value: Bool)
    
    @objc optional func reply(homeTweetCell: HomeTweetCell, sender: UIButton)
}


class HomeTweetCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var retweetCountLabel: UILabel!
    
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    
    weak var delegate: HomeTweetCellDelegate?
    
    var tweetUser: User! {
        didSet {
            if let imageURL = tweetUser.profile_imageUrl_https {
                let imageURLString = imageURL.description.replacingOccurrences(of: "normal.", with: "bigger.")
                let biggerImageURL = URL(string: imageURLString)
                profileImageView.setImageWith(biggerImageURL!)
            }
            
            if let userName = tweetUser.name {
                userNameLabel.text = userName
            }
            
            if let screenName = tweetUser.screenName {
                screenNameLabel.text = "@\(screenName)"
            }
        }
    }
    
    var tweet: Tweet!{
        didSet{
            
            tweetUser = User(dictionary: tweet.user)
            
            if let createdAt = tweet.created_at {
                createdAtLabel.text = createdAt.timeAgo()
            }
            
            if let tweetText = tweet.text {
                tweetTextLabel.text = tweetText
            }
            
            retweetCountLabel.text = tweet.retweet_count.description != "0" ? tweet.retweet_count.description : ""
            isRetweeted = tweet.retweeted
            
            favoriteCountLabel.text = tweet.favorite_count.description != "0" ? tweet.favorite_count.description : ""
            isFavorited = tweet.favorited
        }
    }
    
    var isRetweeted:Bool = false {
        didSet{
            if isRetweeted {
                retweetButton.setImage(UIImage(named: "retweet-action-on"), for: .normal)
                retweetCountLabel.textColor = UIColor(red:0.10, green:0.81, blue:0.53, alpha:1.0) // #19CF86
            } else {
                retweetButton.setImage(UIImage(named: "retweet-action"), for: .normal)
                retweetCountLabel.textColor = UIColor(red:0.67, green:0.72, blue:0.76, alpha:1.0) // #AAB8C2
            }
        }
    }
    
    var isFavorited:Bool = false {
        didSet{
            if isFavorited {
                favoriteButton.setImage(UIImage(named: "like-action-on"), for: .normal)
                favoriteCountLabel.textColor = UIColor(red:0.91, green:0.11, blue:0.31, alpha:1.0) // #E81C4F
            } else {
                favoriteButton.setImage(UIImage(named: "like-action"), for: .normal)
                favoriteCountLabel.textColor = UIColor(red:0.67, green:0.72, blue:0.76, alpha:1.0) // #AAB8C2
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func onReplyButton(_ sender: UIButton) {
        print("reply clicked")
        //self.delegate?.reply!(homeTweetCell: self, sender: sender)
    }
    
    @IBAction func onRetweetButton(_ sender: UIButton) {
        if !isRetweeted {
            TwitterClient.sharedInstance.retweet(id_Int: self.tweet.id, success: { (responseTweet:Tweet) in
                self.tweet = responseTweet
                self.delegate?.retweet!(homeTweetCell: self, didChangeValue: self.isRetweeted)
                print("Retweet: \(self.tweet.retweeted)")
            }) { (error:Error) in
                print("Retweet: Error: \(error.localizedDescription)")
            }
            return
        }
        
        TwitterClient.sharedInstance.unretweet(id_Int: self.tweet.id, success: { (responseTweet:Tweet) in
            self.tweet = responseTweet
            self.delegate?.retweet!(homeTweetCell: self, didChangeValue: self.isRetweeted)
            print("Retweet: \(self.tweet.retweeted)")
        }) { (error:Error) in
            print("UnRetweeted: Error: \(error.localizedDescription)")
        }
    }
    
    @IBAction func onFavoriteButton(_ sender: UIButton) {
        if !isFavorited {
            TwitterClient.sharedInstance.createFavorite(id_Int: self.tweet.id, success: { (responseTweet:Tweet) in
                self.tweet = responseTweet
                self.delegate?.favorite!(homeTweetCell: self, didChangeValue: self.isFavorited)
            }) { (error:Error) in
                print("Create Favorite: Error: \(error.localizedDescription)")
            }
            return
        }
        
        TwitterClient.sharedInstance.destroyFavorite(id_Int: self.tweet.id, success: { (responseTweet:Tweet) in
            self.tweet = responseTweet
            self.delegate?.favorite!(homeTweetCell: self, didChangeValue: self.isFavorited)
        }) { (error:Error) in
            print("Destroy Favorite: Error: \(error.localizedDescription)")
        }
    }
}
