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

class ConversationCell: UITableViewCell {
  
  //MARK: IBOutlets
  @IBOutlet weak var profilePic: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var messageLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  
  //MARK: Private properties
  let userID = UserManager().currentUserID() ?? ""
  
  //MARK: Public methods
  func set(_ conversation: ObjectConversation) {
    timeLabel.text = DateService.shared.format(Date(timeIntervalSince1970: TimeInterval(conversation.timestamp)))
    messageLabel.text = conversation.lastMessage
    guard let id = conversation.userIDs.filter({$0 != userID}).first else { return }
    let isRead = conversation.isRead[userID] ?? true
    if !isRead {
      nameLabel.font = nameLabel.font.bold
      messageLabel.font = messageLabel.font.bold
      messageLabel.textColor = ThemeService.purpleColor
      timeLabel.font = timeLabel.font.bold
    }
    ProfileManager.shared.userData(id: id) {[weak self] profile in
      self?.nameLabel.text = profile?.name
      guard let urlString = profile?.profilePicLink else {
        self?.profilePic.image = UIImage(named: "profile pic")
        return
      }
      self?.profilePic.setImage(url: URL(string: urlString))
    }
  }
  
  //MARK: Lifecycle
  override func prepareForReuse() {
    super.prepareForReuse()
    profilePic.cancelDownload()
    nameLabel.font = nameLabel.font.regular
    messageLabel.font = messageLabel.font.regular
    timeLabel.font = timeLabel.font.regular
    messageLabel.textColor = .gray
    messageLabel.text = nil
  }
}

