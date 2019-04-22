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

class AuthViewController: UIViewController {
  
  //MARK: IBOutlets
  @IBOutlet weak var registerImageView: UIImageView!
  @IBOutlet weak var registerNameTextField: UITextField!
  @IBOutlet weak var registerEmailTextField: UITextField!
  @IBOutlet weak var registerPasswordTextField: UITextField!
  @IBOutlet weak var loginEmailTextField: UITextField!
  @IBOutlet weak var loginPasswordTextField: UITextField!
  @IBOutlet weak var cloudsImageView: UIImageView!
  @IBOutlet weak var cloudsImageViewLeadingConstraint: NSLayoutConstraint!
  @IBOutlet weak var loginViewTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var registerViewTopConstraint: NSLayoutConstraint!

  //MARK: Private properties
  private var selectedImage: UIImage?
  private let manager = UserManager()
  private let imageService = ImagePickerService()
  
  //MARK: Lifecycle
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    animateClouds()
  }
}

//MARK: IBActions
extension AuthViewController {
  
  @IBAction func register(_ sender: Any) {
    guard let name = registerNameTextField.text, let email = registerEmailTextField.text, let password = registerPasswordTextField.text else {
      return
    }
    guard !name.isEmpty else {
      registerNameTextField.borderColor = .red
      return
    }
    guard email.isValidEmail() else {
      registerEmailTextField.borderColor = .red
      return
    }
    guard password.count > 5 else {
      registerPasswordTextField.borderColor = .red
      return
    }
    view.endEditing(true)
    let user = ObjectUser()
    user.name = name
    user.email = email
    user.password = password
    user.profilePic = selectedImage
    ThemeService.showLoading(true)
    manager.register(user: user) {[weak self] response in
      ThemeService.showLoading(false)
      switch response {
        case .failure: self?.showAlert()
        case .success: self?.dismiss(animated: true, completion: nil)
      }
    }
  }
  
  @IBAction func login(_ sender: Any) {
    guard let email = loginEmailTextField.text, let password = loginPasswordTextField.text else {
      return
    }
    guard email.isValidEmail() else {
      loginEmailTextField.borderColor = .red
      return
    }
    guard password.count > 5 else {
      loginPasswordTextField.borderColor = .red
      return
    }
    view.endEditing(true)
    let user = ObjectUser()
    user.email = email
    user.password = password
    ThemeService.showLoading(true)
    manager.login(user: user) {[weak self] response in
      ThemeService.showLoading(false)
      switch response {
      case .failure: self?.showAlert()
      case .success: self?.dismiss(animated: true, completion: nil)
      }
    }
  }
  
  @IBAction func switchViews(_ sender: UIButton) {
    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
      self.view.layoutIfNeeded()
    })
  }
  
  @IBAction func profileImage(_ sender: Any) {
    imageService.pickImage(from: self) {[weak self] image in
      self?.registerImageView.image = image
      self?.selectedImage = image
    }
  }
}

//MARK: Private methods
extension AuthViewController {
  
  private func animateClouds() {
    let distance = view.bounds.width - cloudsImageView.bounds.width
    self.cloudsImageViewLeadingConstraint.constant = distance
    UIView.animate(withDuration: 15, delay: 0, options: [.repeat, .curveLinear], animations: {
      self.view.layoutIfNeeded()
    })
  }
}

//MARK: UITextField Delegate
extension AuthViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    return textField.resignFirstResponder()
  }
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    textField.borderColor = ThemeService.purpleColor
  }
}
