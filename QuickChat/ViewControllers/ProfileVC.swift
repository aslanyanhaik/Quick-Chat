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

    override func viewDidLoad() {
        super.viewDidLoad()
        if let id  = FIRAuth.auth()?.currentUser?.uid {
            FIRDatabase.database().reference().child("users").child(id).observe(.value, with: { (snapshot) in
                let value = snapshot.value as! [String : String]
                self.nameLabel.text = value["email"]
            })
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
