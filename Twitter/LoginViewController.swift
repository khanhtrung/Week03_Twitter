//
//  LoginViewController.swift
//  Twitter
//
//  Created by Tran Khanh Trung on 10/27/16.
//  Copyright © 2016 TRUNG. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLogin(_ sender: UIButton) {
        
        let twitterClient = BDBOAuth1SessionManager(
            baseURL: NSURL(string: "https://api.twitter.com/") as URL!,
            consumerKey: "pMEdajjkOcc9sRphXlWrHUofr",
            consumerSecret: "ge7Q2aBBgcuiQmQLPPJmwnwIbIRNF0SBMuwSlQEBXqWLzM3D9M")
        
        twitterClient?.fetchRequestToken(withPath: "oauth/request_token",
                                         method: "POST",
                                         callbackURL: URL(string: "TheSwiftBird://oath") as URL!,
                                         scope: nil, success: { (response: BDBOAuth1Credential?) in
            print("Request token >\((response?.token)!)<")
            
            let authURL = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\((response?.token)!)")
            UIApplication.shared.open(authURL!, options: [:]) { (response) in
                //
            }
            
            }, failure: { (error: Error?) in
                print("\(error?.localizedDescription)")
        })
        
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
