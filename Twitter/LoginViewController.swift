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
        //MARK: - REQUEST TOKEN
        TwitterClient.sharedInstance.login(success: {
            print("Message after loged in")
            self.performSegue(withIdentifier: "LoginSegue", sender: nil)
            
        }) { (error: Error) in
            print("Error: \(error.localizedDescription)")
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
