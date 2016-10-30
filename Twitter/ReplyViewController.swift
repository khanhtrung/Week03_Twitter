//
//  ReplyViewController.swift
//  Twitter
//
//  Created by Tran Khanh Trung on 10/30/16.
//  Copyright © 2016 TRUNG. All rights reserved.
//

import UIKit

class ReplyViewController: UIViewController {

    @IBOutlet weak var userProfileImage: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    var tweetUser: User! {
        didSet {
            if let imageURL = tweetUser.profile_imageUrl_https {
                let imageURLString = imageURL.description.replacingOccurrences(of: "normal.", with: "bigger.")
                let biggerImageURL = URL(string: imageURLString)
                let imageView = UIImageView()
                imageView.setImageWith(biggerImageURL!)
                userProfileImage.image = imageView.image
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onDismissView(_ sender: UIBarButtonItem) {
//        navigationController?.popViewController(animated: true)
        
        dismiss(animated: true, completion: nil)
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
