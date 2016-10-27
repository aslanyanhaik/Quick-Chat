//
//  ConversationsTB.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 10/17/16.
//  Copyright © 2016 Mexonis. All rights reserved.
//

import UIKit
import Firebase

class ConversationsTB: UITableViewController {
    
    
    //MARK: Properties
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }

        
    func customization()  {
        
        UINavigationBar.appearance().setBackgroundImage(UIImage(named: "button")!.resizableImage(withCapInsets: UIEdgeInsetsMake(0, 0, 0, 0), resizingMode: .stretch), for: .default)



    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customization()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }


}








