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

protocol MessageTableViewCellDelegate: class {
  func messageTableViewCellUpdate()
}

class MessageTableViewCell: UITableViewCell {
  
  @IBOutlet weak var profilePic: UIImageView?
  @IBOutlet weak var messageTextView: UITextView?
  
  func set(_ message: ObjectMessage) {
    messageTextView?.text = message.message
    guard let imageView = profilePic else { return }
    guard let userID = message.ownerID else { return }
    ProfileManager.shared.userData(id: userID) { user in
      guard let urlString = user?.profilePicLink else { return }
      imageView.setImage(url: URL(string: urlString))
    }
  }
}

class MessageAttachmentTableViewCell: MessageTableViewCell {
  
  @IBOutlet weak var attachmentImageView: UIImageView!
  @IBOutlet weak var attachmentImageViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var attachmentImageViewWidthConstraint: NSLayoutConstraint!
  weak var delegate: MessageTableViewCellDelegate?
  
  override func prepareForReuse() {
    super.prepareForReuse()
    attachmentImageView.cancelDownload()
    attachmentImageView.image = nil
    attachmentImageViewHeightConstraint.constant = 250 / 1.3
    attachmentImageViewWidthConstraint.constant = 250
  }
  
  override func set(_ message: ObjectMessage) {
    super.set(message)
    switch message.contentType {
    case .location:
      attachmentImageView.image = UIImage(named: "locationThumbnail")
    case .photo:
      guard let urlString = message.profilePicLink else { return }
      attachmentImageView.setImage(url: URL(string: urlString)) {[weak self] image in
        guard let image = image, let weakSelf = self else { return }
        guard weakSelf.attachmentImageViewHeightConstraint.constant != image.size.height, weakSelf.attachmentImageViewWidthConstraint.constant != image.size.width else { return }
        if max(image.size.height, image.size.width) <= 250 {
          weakSelf.attachmentImageViewHeightConstraint.constant = image.size.height
          weakSelf.attachmentImageViewWidthConstraint.constant = image.size.width
          weakSelf.delegate?.messageTableViewCellUpdate()
          return
        }
        weakSelf.attachmentImageViewWidthConstraint.constant = 250
        weakSelf.attachmentImageViewHeightConstraint.constant = image.size.height * (250 / image.size.width)
        weakSelf.delegate?.messageTableViewCellUpdate()
      }
    default: break
    }
  }
}
