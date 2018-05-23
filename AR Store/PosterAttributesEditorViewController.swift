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
    
  @IBOutlet var scnView: PosterAttributesEditorView!
  @IBOutlet var periodTextField: DarkTextField!
  @IBOutlet var specialOfferTextView: DarkTextView!
  @IBOutlet var nextBtn: RoundButton!
  var editFinishedDelegate: ((_ period: String, _ specialOffer: String) -> Void)!
  
  private var initialPeriod: String? = nil
  private var initialSpecialOffer: String? = nil
  
  func initData(period: String, specialOffer: String) {
    initialPeriod = period
    initialSpecialOffer = specialOffer
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if (initialPeriod != nil) {
      periodTextField.text = initialPeriod!
    }
    
    if (initialSpecialOffer != nil) {
      specialOfferTextView.text = initialSpecialOffer!
    }
  }
  
  func doOnEditFinished(delegate: @escaping ((_ period: String, _ specialOffer: String) -> Void)) {
    self.editFinishedDelegate = delegate
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
    self.editFinishedDelegate(self.periodTextField.text!, self.specialOfferTextView.text!)
    self.dismiss(animated: true, completion: nil)
  }
}
