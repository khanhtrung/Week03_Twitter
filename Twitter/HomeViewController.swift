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
    var refreshControl: UIRefreshControl!
    
    var loadingMoreView: InfiniteScrollActivityView?
    var isMoreDataLoading = false
    var max_id: Int64 = 0
    
    var tweets = [Tweet]()
    var retweetStates = [Int:Bool]()
    var favoriteStates = [Int:Bool]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initHomeVC()
        triggerRefresh()
    }
    
    func initHomeVC(){
        // Setup tableView
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150
        
        // Setup Refresh control
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(triggerRefresh), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: tableView.contentSize.height,
                           width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
        // -- END OF Set up Infinite Scroll loading indicator
    }
    
    func triggerRefresh(){
        self.max_id = 0
        self.refreshControl.beginRefreshing()
        getHomeTimeline()
    }
    
    func getHomeTimeline() {
        
        var params: NSDictionary = NSDictionary()
        if max_id != 0 {
            params = [ "max_id": max_id]
            print("LOAD MORE, max_id: >\(max_id)<")
        } else {print("Refresh")}
        
        TwitterClient.sharedInstance.homeTimelineWith(params: params) { (successTweets, error) in
            if error != nil {
                print("====>> Home View did load: Error: \(error?.localizedDescription)")
                return
            }
            print("Got Tweets")
            
            if self.max_id != 0 {
                if var tweets = successTweets {
                    tweets.removeFirst()
                    self.tweets.append(contentsOf: tweets)
                }
            } else {
                self.tweets = successTweets!
            }
            self.tableView.reloadData()
            
            // For infinite loading feature
            if let lastTweet = self.tweets.last {
                self.max_id = lastTweet.id
            }
            self.isMoreDataLoading = false
            self.loadingMoreView!.stopAnimating()
            
            self.refreshControl.endRefreshing()
        }
    }
    
    @IBAction func onLogoutButton(_ sender: AnyObject) {
        TwitterClient.sharedInstance.logout()
    }
    
    @IBAction func onNewTweetButton(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "newTweetSegue", sender: self)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let segueID = segue.identifier {
            switch segueID {
            case "newTweetSegue":
                let nav = segue.destination as! UINavigationController
                let newTweetViewController = nav.topViewController as! NewTweetViewController
                newTweetViewController.tweetUser = User.currentUser!
                newTweetViewController.delegate = self
                break
                
            case "tweetSegueFromTimeline":
                let cell = sender as! UITableViewCell
                let indexpath = tableView.indexPath(for: cell)
                let tweet = tweets[(indexpath?.row)!]
                
                let tweetViewController = segue.destination as! TweetViewController
                tweetViewController.id = tweet.id
                break
            default:
                break
            }
        }
    }
}

//MARK: - Table methods
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTweetCell", for: indexPath) as! HomeTweetCell
        cell.tweet = tweets[indexPath.row]
        cell.delegate = self
        return cell
    }
}

//MARK: - Check Cell methods
extension HomeViewController: HomeTweetCellDelegate {
    
    func retweet(homeTweetCell: HomeTweetCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPath(for: homeTweetCell)!
        retweetStates[indexPath.row] = homeTweetCell.isRetweeted
        tweets[indexPath.row] = homeTweetCell.tweet
        print("Retweet - Have to update UI")
    }
    
    func favorite(homeTweetCell: HomeTweetCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPath(for: homeTweetCell)!
        favoriteStates[indexPath.row] = homeTweetCell.isFavorited
        tweets[indexPath.row] = homeTweetCell.tweet
        print("Favorite - Have to update UI")
    }
    
    func reply(homeTweetCell: HomeTweetCell, sender: UIButton) {
        self.performSegue(withIdentifier: "replyTweetSegueFromTimeline", sender: sender)
    }
}

//MARK: - NewTweetViewController methods
extension HomeViewController: NewTweetViewControllerDelegate {
    func newTweetViewController(newTweetViewController: NewTweetViewController, didUpdateTweet tweet: Tweet?) {
        tweets.insert(tweet!, at: 0)
        tableView.reloadData()
    }
}

//MARK: - UIScrollViewDelegate methods
extension HomeViewController: UIScrollViewDelegate {
    // any offset changes
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            
            // Calculate the position of one screen length before the bottom of the results
            let contentHeight = scrollView.contentSize.height
            let offsetThreshold = contentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > offsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x:0, y:tableView.contentSize.height,
                                   width:tableView.bounds.size.width, height:InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                // Load more tweets
                getHomeTimeline()
            }
            
        }
    }
}

//MARK: - Infinite Scroll ActivityView
class InfiniteScrollActivityView: UIView {
    var activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
    static let defaultHeight:CGFloat = 60.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupActivityIndicator()
    }
    
    override init(frame aRect: CGRect) {
        super.init(frame: aRect)
        setupActivityIndicator()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        activityIndicatorView.center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
    }
    
    func setupActivityIndicator() {
        activityIndicatorView.activityIndicatorViewStyle = .gray
        activityIndicatorView.hidesWhenStopped = true
        self.addSubview(activityIndicatorView)
    }
    
    func stopAnimating() {
        self.activityIndicatorView.stopAnimating()
        self.isHidden = true
    }
    
    func startAnimating() {
        self.isHidden = false
        self.activityIndicatorView.startAnimating()
    }
}
