//
//  NewTweetViewController.swift
//  Twitter
//
//  Created by Tran Khanh Trung on 10/31/16.
//  Copyright © 2016 TRUNG. All rights reserved.
//

import UIKit

@objc protocol NewTweetViewControllerDelegate {
    @objc func newTweetViewController(newTweetViewController: NewTweetViewController, didUpdateTweet tweet: Tweet?)
}

class NewTweetViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var charsCountLabel: UILabel!
    @IBOutlet weak var tweetTextField: UITextField!
    
    var tweetUser: User!
    weak var delegate: NewTweetViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tweetTextField.becomeFirstResponder()
        tweetTextField.text = ""
        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onCancelButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTweetButton(_ sender: UIBarButtonItem) {
        TwitterClient.sharedInstance.updateStatuses(status: tweetTextField.text!) { (successTweet, error) in
            if error != nil {
                print("====>> New Tweet post: Error: \(error?.localizedDescription)")
                return
            }
            print("Post new tweet OK")
            self.tweetUser = User(dictionary: (successTweet?.user)!)
            
            self.delegate?.newTweetViewController(newTweetViewController: self, didUpdateTweet: successTweet)
            
            self.dismiss(animated: true, completion: nil)
        }
    }
}
