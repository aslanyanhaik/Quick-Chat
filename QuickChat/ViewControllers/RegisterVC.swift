//
//  RegisterVC.swift
//  QuickChat
//
//  Created by Haik Aslanyan on 11/1/16.
//  Copyright © 2016 Mexonis. All rights reserved.
//

import UIKit
import Photos

class RegisterVC: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    //MARK: Properties
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    let imagePicker = UIImagePickerController()
    var delegate: SuccessfulAuthentication?
    
    
    //MARK: Methods
    func customization()  {
        self.imagePicker.delegate = self
        self.submitButton.layer.cornerRadius = 20
        self.submitButton.clipsToBounds = true
        self.profilePic.layer.cornerRadius = 35
        self.profilePic.clipsToBounds = true
        self.profilePic.layer.borderWidth = 1
        self.profilePic.layer.borderColor = GlobalVariables.blue.cgColor
    }
    
    @IBAction func selectPic(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum;
            self.imagePicker.allowsEditing = true
            self.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func registerUser(_ sender: Any) {
        self.delegate?.didAuthenticate()
    }
   
    //MARK: Delegates
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.profilePic.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: ViewController lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customization()
    }
}
