//
//  Designer.swift
//  AR Store
//
//  Created by Admin on 23.05.2018.
//  Copyright © 2018 Vertical. All rights reserved.
//

import Foundation
import UIKit

class RoundButton: UIButton {
  override func didMoveToWindow() {
    self.backgroundColor = UIColor.darkGray
    self.layer.cornerRadius = self.frame.height / 2
    self.setTitleColor(UIColor.white, for: .normal)
    self.layer.shadowColor = UIColor.darkGray.cgColor
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
    self.backgroundColor = UIColor.darkGray.withAlphaComponent(0.7)
    self.textColor = UIColor.white
    self.clipsToBounds = true
    self.layer.cornerRadius = 10
    self.layer.shadowColor = UIColor.darkGray.cgColor
    self.layer.shadowRadius = 4
    self.layer.shadowOpacity = 0.5
    self.layer.shadowOffset = CGSize(width: 0, height: 0)
  }
}

class DarkTextView: UITextView {
  override func didMoveToWindow() {
    self.backgroundColor = UIColor.darkGray.withAlphaComponent(0.7)
    self.textColor = UIColor.white
    self.clipsToBounds = true
    self.layer.cornerRadius = 10
    self.layer.shadowColor = UIColor.darkGray.cgColor
    self.layer.shadowRadius = 4
    self.layer.shadowOpacity = 0.5
    self.layer.shadowOffset = CGSize(width: 0, height: 0)
  }
}
