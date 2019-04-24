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

class UILabelGradient: UILabel {
  
  @IBInspectable var leftColor: UIColor = ThemeService.purpleColor {
    didSet {
      applyGradient()
    }
  }
  
  @IBInspectable var rightColor: UIColor = ThemeService.blueColor {
    didSet {
      applyGradient()
    }
  }
  
  override var text: String? {
    didSet {
      applyGradient()
    }
  }
  
  func applyGradient() {
    let gradientLayer = CAGradientLayer()
    gradientLayer.colors = [leftColor.cgColor, rightColor.cgColor]
    gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
    gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
    let textSize = NSAttributedString(string: text ?? "", attributes: [.font: font!]).size()
    gradientLayer.bounds = CGRect(origin: .zero, size: textSize)
    UIGraphicsBeginImageContextWithOptions(gradientLayer.bounds.size, true, 0.0)
    let context = UIGraphicsGetCurrentContext()
    gradientLayer.render(in: context!)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    textColor = UIColor(patternImage: image!)
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    applyGradient()
  }
}
