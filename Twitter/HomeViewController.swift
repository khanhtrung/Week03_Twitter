//
//  HomeViewController.swift
//  Twitter
//
//  Created by Tran Khanh Trung on 10/29/16.
//  Copyright © 2016 TRUNG. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var tweets = [Tweet]()
    var retweetStates = [Int:Bool]()
    var favoriteStates = [Int:Bool]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup tableView
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150
        
        getHomeTimeline()
    }
    
    func getHomeTimeline(){
        TwitterClient.sharedInstance.homeTimeline(success: { (tweets:[Tweet]) in
            self.tweets.removeAll()
            self.tweets = tweets
            self.tableView.reloadData()
            
        }) { (error: Error) in
            print("Home View did load: Error: \(error.localizedDescription)")
        }
    }
    
    @IBAction func onLogoutButton(_ sender: AnyObject) {
        TwitterClient.sharedInstance.logout()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

//MARK: - Table methods
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTweetCell", for: indexPath) as! HomeTweetCell
        cell.tweet = tweets[indexPath.row]
        //        cell.isRetweeted = cell.tweet.retweeted
        //        cell.isFavorited = cell.tweet.favorited
        cell.delegate = self
        return cell
    }
}

//MARK: - Check Cell methods
extension HomeViewController: HomeTweetCellDelegate {
    
    func retweet(homeTweetCell: HomeTweetCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPath(for: homeTweetCell)!
        retweetStates[indexPath.row] = homeTweetCell.isRetweeted
    }
    
    func favorite(homeTweetCell: HomeTweetCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPath(for: homeTweetCell)!
        favoriteStates[indexPath.row] = homeTweetCell.isFavorited
    }
}

