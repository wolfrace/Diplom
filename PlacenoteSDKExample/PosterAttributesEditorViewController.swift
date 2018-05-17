//
//  PosterAttributesEditorViewController.swift
//  PlacenoteSDKExample
//
//  Created by Admin on 17.05.2018.
//  Copyright © 2018 Vertical. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

class PosterAttributesEditorViewController
: UIViewController {
    
  @IBOutlet var scnView: UIView!
  @IBOutlet weak var periodTextField: UITextField!
  @IBOutlet weak var specialOfferTextView: UITextView!
  @IBOutlet weak var nextBtn: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.specialOfferTextView.layer.borderColor = UIColor.black.cgColor
    self.specialOfferTextView.layer.borderWidth = 1
    self.specialOfferTextView.layer.cornerRadius = 5
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  //Initialize view and scene
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.view.endEditing(true)
  }
  
  @IBAction func OnNextBtn(_ sender: Any) {
    print("OnNextButton")
    self.dismiss(animated: true, completion: nil)
  }
}
