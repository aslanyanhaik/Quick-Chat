//
//  ComposeTB.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 10/26/16.
//  Copyright © 2016 Mexonis. All rights reserved.
//

import UIKit
import Firebase

protocol ComposeVCDelegate {
    func id(id: String)
}

class ComposeTB: UITableViewController {
    
    var items = [User]()
    var delegate: ComposeVCDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchUsers()
        self.navigationItem.title = "aaa"
        
        
    }

    @IBAction func cancelView(_ sender: AnyObject) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func fetchUsers()  {
        
         GlobalVariables.users.observe(.childAdded, with: { (snapshot) in
            let output = snapshot.value as! [String: String]
            let name = output["name"]!
            let email = output["email"]!
            let profilePicLink = output["profilePicLink"]!
                let link = URL.init(string: profilePicLink)
                let data = try! Data.init(contentsOf: link!)
                let profilePic = UIImage.init(data: data)!
            let user = User.init(name: name, email: email, id: snapshot.key, profilePicLink: link!, profilePic: profilePic)
                self.items.append(user)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
         })
        }

    // MARK: - TableView Delegates

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UsersCell
        cell.nameLabel.text = self.items[indexPath.row].name
        cell.emailLabel.text = self.items[indexPath.row].email
        cell.imageView?.image = self.items[indexPath.row].profilePic
        return cell
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let id = items[indexPath.row].id
        self.delegate?.id(id: id)
        self.dismiss(animated: true, completion: nil)
    }
}





class UsersCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var profilePicView: UIImageView!
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

