//  MIT License

//  Copyright (c) 2019 Haik Aslanyan

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.


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
