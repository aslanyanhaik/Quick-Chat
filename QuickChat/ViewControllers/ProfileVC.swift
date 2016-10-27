//
//  ProfileVC.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 10/17/16.
//  Copyright © 2016 Mexonis. All rights reserved.
//

import UIKit
import Firebase

class ProfileVC: UIViewController {
    
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var profilePicView: UIImageView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        if let id  = FIRAuth.auth()?.currentUser?.uid {
            FIRDatabase.database().reference().child("users").child(id).observe(.value, with: { (snapshot) in
                let value = snapshot.value as! [String : String]
                self.nameLabel.text = value["email"]
                self.emailLabel.text = value["name"]
                let profilePicURL = URL.init(string: value["profilePicLink"]!)
                let imageData = try! Data.init(contentsOf: profilePicURL!)
                let profilePic = UIImage.init(data: imageData)
                self.profilePicView.image = profilePic
            })
        }
            }
    @IBAction func logOut(_ sender: AnyObject) {

        if let _ = FIRAuth.auth()?.currentUser?.uid {
            do {
                try FIRAuth.auth()?.signOut()
            } catch _ {
                print("something went wrong")
            }
        }
        
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
