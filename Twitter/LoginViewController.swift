//
//  LoginViewController.swift
//  Twitter
//
//  Created by Tran Khanh Trung on 10/27/16.
//  Copyright © 2016 TRUNG. All rights reserved.
//

import UIKit
import BDBOAuth1Manager
import Reachability

class LoginViewController: UIViewController {
    
    @IBOutlet weak var networkErrorView: UIView!
    var reachability: Reachability?
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Button corner
        loginButton.layer.cornerRadius = 5
        
        // Shadow
        loginButton.layer.shadowColor = UIColor(white: 0x000000, alpha: 0.2).cgColor
        loginButton.layer.shadowOpacity = 1.0
        loginButton.layer.shadowRadius = 0
        loginButton.layer.masksToBounds = false
        loginButton.layer.shadowOffset = CGSize(width: 0,height: 0.75)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupReachability()
        setErrorViewHidden()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLogin(_ sender: UIButton) {
        //MARK: - REQUEST TOKEN
        TwitterClient.sharedInstance.login(success: {
            print("Message after loged in")
            self.performSegue(withIdentifier: "LoginSegue", sender: nil)
            
        }) { (error: Error) in
            print("Login Error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Reachability Setup
    func setupReachability(){
        // Allocate a reachability object
        self.reachability = Reachability.forInternetConnection()
        
        // Tell the reachability that we DON'T want to be reachable on 3G/EDGE/CDMA
        self.reachability!.reachableOnWWAN = false
        
        // Here we set up a NSNotification observer. The Reachability that caused the notification
        // is passed in the object parameter
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reachabilityChanged),
                                               name: NSNotification.Name.reachabilityChanged,
                                               object: nil)
        
        self.reachability!.startNotifier()
    }
    
    func reachabilityChanged(notification: NSNotification) {
        setErrorViewHidden()
    }
    
    func setErrorViewHidden(){
        if self.reachability!.isReachableViaWiFi() || self.reachability!.isReachableViaWWAN() {
            print("Service avalaible!")
            self.networkErrorView.isHidden = true
        } else {
            print("No service avalaible!")
            self.networkErrorView.isHidden = false
        }
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
