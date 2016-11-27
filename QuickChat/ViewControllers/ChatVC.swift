//
//  ChatVC.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 10/28/16.
//  Copyright © 2016 Mexonis. All rights reserved.
//

import UIKit

class ChatVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    var userName = "Name"
    
    //MARK: Methods
    func customization() {
        self.navigationItem.title = self.userName
        self.navigationItem.setHidesBackButton(true, animated: false)
        let icon = UIImage.init(named: "back")?.withRenderingMode(.alwaysOriginal)
        let rightButton = UIBarButtonItem.init(image: icon!, style: .plain, target: self, action: #selector(ChatVC.dismissSelf))
        self.navigationItem.leftBarButtonItem = rightButton
    }
    
    func dismissSelf() {
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
    
    //MARK: Delegates
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "Random messages"
        return cell
    }
    
    //MARK: ViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customization()
    }
}
