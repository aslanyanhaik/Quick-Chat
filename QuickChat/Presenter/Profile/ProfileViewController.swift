//
//  ProfileViewController.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 4/24/19.
//  Copyright © 2019 Mexonis. All rights reserved.
//

import UIKit

protocol ProfileViewControllerDelegate: class {
  func profileViewControllerDidLogOut()
}

class ProfileViewController: UIViewController {
  
  //MARK: IBOutlets
  @IBOutlet weak var backgroundView: UIButton!
  @IBOutlet weak var profileImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var emailLabel: UILabel!
  @IBOutlet weak var horizontalConstraint: NSLayoutConstraint!

  //MARK: Public properties
  var user: ObjectUser?
  var delegate: ProfileViewControllerDelegate?
  
  //MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    nameLabel.text = user?.name
    emailLabel.text = user?.email
    if let urlString = user?.profilePicLink {
      profileImageView.setImage(url: URL(string: urlString))
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    horizontalConstraint.constant = 0
    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
      self.backgroundView.alpha = 0.8
      self.view.layoutIfNeeded()
    })
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    profileImageView.cornerRadius = profileImageView.bounds.width / 2
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    modalPresentationStyle = .overFullScreen
  }
}

//MARK: IBActions
extension ProfileViewController {
  
  @IBAction func closePressed(_ sender: Any) {
    horizontalConstraint.constant = view.bounds.height
    UIView.animate(withDuration: 0.3, animations: {
      self.backgroundView.alpha = 0
      self.view.layoutIfNeeded()
    }) { _ in
      self.dismiss(animated: false, completion: nil)
    }
  }
  
  @IBAction func logOutPressed(_ sender: Any) {
    horizontalConstraint.constant = view.bounds.height
    UIView.animate(withDuration: 0.3, animations: {
      self.backgroundView.alpha = 0
      self.view.layoutIfNeeded()
    }) { _ in
      self.dismiss(animated: false, completion: {
        self.delegate?.profileViewControllerDidLogOut()
      })
    }
  }
}
