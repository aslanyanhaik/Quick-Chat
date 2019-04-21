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

import Foundation

import UIKit
import Photos

class ImagePickerService: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  private lazy var picker: UIImagePickerController = {
    let picker = UIImagePickerController()
    picker.delegate = self
    picker.allowsEditing = true
    return picker
  }()
  var completionBlock: CompletionObject<UIImage>?
  
  func pickImage(from vc: UIViewController, completion: CompletionObject<UIImage>?) {
    completionBlock = completion
    let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    sheet.view.tintColor = UIColor.black
    let cameraAction = UIAlertAction(title: "Camera", style: .default) {[weak self] _ in
      guard let weakSelf = self else { return }
      weakSelf.picker.sourceType = .camera
      vc.present(weakSelf.picker, animated: true, completion: nil)
    }
    let photoAction = UIAlertAction(title: "Gallery", style: .default) {[weak self] _ in
      guard let weakSelf = self else { return }
      weakSelf.picker.sourceType = .photoLibrary
      vc.present(weakSelf.picker, animated: true, completion: nil)
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    sheet.addAction(cameraAction)
    sheet.addAction(photoAction)
    sheet.addAction(cancelAction)
    vc.present(sheet, animated: true, completion: nil)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    if let image = info[.editedImage] as? UIImage {
      completionBlock?(image.fixOrientation())
    }
    picker.dismiss(animated: true, completion: nil)
  }
}
