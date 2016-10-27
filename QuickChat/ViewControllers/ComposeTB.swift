//
//  ComposeTB.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 10/26/16.
//  Copyright © 2016 Mexonis. All rights reserved.
//

import UIKit
import Firebase

class ComposeTB: UITableViewController {
    
    var items = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchUsers()
        self.navigationItem.title = "aaa"
    }

    
    func fetchUsers()  {
        
         FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            let output = snapshot.value as! [String: String]
            let name = output["name"]
            let email = output["email"]
            let profilePicLink = output["profilePicLink"]
            let user = User.init(name: name!, email: email!, profilePicLink: profilePicLink!)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = self.items[indexPath.row].name
        cell.detailTextLabel?.text = self.items[indexPath.row].email
        return cell
    }

}
