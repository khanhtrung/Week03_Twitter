//
//  TweetViewController.swift
//  Twitter
//
//  Created by Tran Khanh Trung on 10/30/16.
//  Copyright © 2016 TRUNG. All rights reserved.
//

import UIKit

@objc protocol TweetViewControllerDelegate {
    @objc func tweetViewController(tweetViewController: TweetViewController, didUpdateTweet tweet: Tweet?, homeTweetCellIndexPath: IndexPath)
}

class TweetViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var id: Int64 = 0
    var tweets = [Tweet]()
    var retweetStates = [Int:Bool]()
    var favoriteStates = [Int:Bool]()
    weak var delegate: TweetViewControllerDelegate?
    var homeTweetCellIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup tableView
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150
        
        lookupStatuses()
    }
    
    func lookupStatuses(){
        TwitterClient.sharedInstance.lookupStatuses(id_Int: self.id, success: { (tweets:[Tweet]) in
            self.tweets.removeAll()
            self.tweets = tweets
            self.tableView.reloadData()
        }) { (error: Error) in
            print("Tweet View did load: Error: \(error.localizedDescription)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        
        // exit if just opened from home time line
        if parent != nil {
            return
        }
        
        // Get newest content for current tweet, to update current cell in home timeline view
        var params: NSDictionary = NSDictionary()
        params = ["id": self.id]
        TwitterClient.sharedInstance.showStatusByID(params: params) { (successTweet, error) in
            if error != nil {
                print("====>> getTweetBy: Error: \(error?.localizedDescription)")
                return
            }
            if let tweet = successTweet {
                self.delegate?.tweetViewController(tweetViewController: self, didUpdateTweet: tweet, homeTweetCellIndexPath: self.homeTweetCellIndexPath!)
            }
        }
    }
    
}

//MARK: - Table methods
extension TweetViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTweetCell", for: indexPath) as! HomeTweetCell
        cell.tweet = tweets[indexPath.row]
        cell.delegate = self
        return cell
    }
}

//MARK: - Check Cell methods
extension TweetViewController: HomeTweetCellDelegate {
    
    func retweet(homeTweetCell: HomeTweetCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPath(for: homeTweetCell)!
        retweetStates[indexPath.row] = homeTweetCell.isRetweeted
    }
    
    func favorite(homeTweetCell: HomeTweetCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPath(for: homeTweetCell)!
        favoriteStates[indexPath.row] = homeTweetCell.isFavorited
    }
}
