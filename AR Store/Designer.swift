//
//  Designer.swift
//  AR Store
//
//  Created by Admin on 23.05.2018.
//  Copyright © 2018 Vertical. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
  convenience init(hexString: String) {
    let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int = UInt32()
    Scanner(string: hex).scanHexInt32(&int)
    let a, r, g, b: UInt32
    switch hex.characters.count {
    case 3: // RGB (12-bit)
      (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
    case 6: // RGB (24-bit)
      (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
    case 8: // ARGB (32-bit)
      (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
    default:
      (a, r, g, b) = (255, 0, 0, 0)
    }
    self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
  }
}

class RoundButton: UIButton {
  override func didMoveToWindow() {
    self.backgroundColor = UIColor(hexString: "#4f9cdf")
    self.layer.cornerRadius = self.frame.height / 2
    self.setTitleColor(UIColor.white, for: .normal)
    self.layer.shadowColor = UIColor.blue.cgColor
    self.layer.shadowRadius = 4
    self.layer.shadowOpacity = 0.5
    self.layer.shadowOffset = CGSize(width: 0, height: 0)
  }

}

class DarkLabel: UILabel {
  override func didMoveToWindow() {
    self.backgroundColor = UIColor.darkGray.withAlphaComponent(0.35)
    self.textColor = UIColor.white
    self.layer.shadowColor = UIColor.darkGray.cgColor
    self.layer.shadowOpacity = 0.5
    self.layer.shadowOffset = CGSize(width: 0, height: 0)
  }
}

class DarkTextField: UITextField {
  override func didMoveToWindow() {
    self.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
    self.textColor = UIColor.white
    let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.frame.size.height))
    self.leftView = paddingView
    self.leftViewMode = .always
//    self.clipsToBounds = true
//    self.layer.cornerRadius = 10
//    self.layer.shadowColor = UIColor.darkGray.cgColor
//    self.layer.shadowRadius = 4
//    self.layer.shadowOpacity = 0.5
//    self.layer.shadowOffset = CGSize(width: 0, height: 0)
  }
}

class DarkTextView: UITextView {
  override func didMoveToWindow() {
    self.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
    self.textColor = UIColor.white
    self.contentInset = UIEdgeInsetsMake(8, 7, 0, 0)
//    self.clipsToBounds = true
//    self.layer.cornerRadius = 10
//    self.layer.shadowColor = UIColor.darkGray.cgColor
//    self.layer.shadowRadius = 4
//    self.layer.shadowOpacity = 0.5
//    self.layer.shadowOffset = CGSize(width: 0, height: 0)
  }
}

class PosterAttributesEditorView: UIView {
  override func didMoveToWindow() {
    let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
    backgroundImage.image = UIImage(named: "background.png")
    backgroundImage.contentMode = UIViewContentMode.scaleAspectFill
    self.insertSubview(backgroundImage, at: 0)
  }
}
