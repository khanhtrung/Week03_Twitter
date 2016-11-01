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
    @IBOutlet weak var tweetTextView: UITextView!
    @IBOutlet weak var tweetButton: UIBarButtonItem!
    
    var tweetUser: User!
    weak var delegate: NewTweetViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tweetTextView.becomeFirstResponder()
        tweetTextView.delegate = self
        tweetTextView.text = ""
        
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
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let currentCharacterCount = textField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.characters.count - range.length
        return newLength <= 25
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onCancelButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTweetButton(_ sender: UIBarButtonItem) {
        TwitterClient.sharedInstance.updateStatuses(status: tweetTextView.text!) { (successTweet, error) in
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

//MARK: - UITextView methods
extension NewTweetViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newLength = (textView.text?.utf16.count)! + text.utf16.count - range.length
        
        //Update the value of the label
        charsCountLabel.text =  String(140 - newLength)
        
        // Set text color for the label
        if (newLength >= 0) && (newLength <= 120) {
            charsCountLabel.textColor = UIColor(red:0.67, green:0.72, blue:0.76, alpha:1.0)
        } else {
            charsCountLabel.textColor = UIColor.red
        }
        
        // Lock Tweet button if text length greater than 140
        tweetButton.isEnabled = !(newLength > 140)
        
        // Not allow enter greater than 150 chars
        return newLength < 160
    }
}
