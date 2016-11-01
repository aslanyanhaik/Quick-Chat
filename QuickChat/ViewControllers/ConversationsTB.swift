//
//  ConversationsTB.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 10/17/16.
//  Copyright © 2016 Mexonis. All rights reserved.
//

import UIKit
import Firebase

class ConversationsTB: UITableViewController, ComposeVCDelegate {
    
    
    //MARK: Properties
    var items = [String]()
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }

    @IBAction func compose(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Compose") as! ComposeTB
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
        
    func customization()  {
        
        UINavigationBar.appearance().setBackgroundImage(UIImage(named: "button")!.resizableImage(withCapInsets: UIEdgeInsetsMake(0, 0, 0, 0), resizingMode: .stretch), for: .default)



    }
    
    func id(id: String) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Chat") as! ChatVC
        vc.id = id
        print(id)
        self.show(vc, sender: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customization()
        
        
        if let id = FIRAuth.auth()?.currentUser?.uid {
            GlobalVariables.users.child(id).child("conversations").observe(.value, with: { (snapshot) in
                if let value = snapshot.value as? [String : String] {
                    let userId = value["toID"]
                    GlobalVariables.users.child(userId!).observe(.value, with: { (userSnapshot) in
                        let userValue = userSnapshot.value as! [String : String]
                        let name = userValue["name"]!
                        self.items.append(name)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    })
                }
            })
        }
    }

 

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.items.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = self.items[indexPath.row]
        return cell
    }
    
}








