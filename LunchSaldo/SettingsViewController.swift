//
//  SettingsViewController.swift
//  LunchSaldo
//
//  Created by Martin Furuberg on 2015-01-22.
//  Copyright (c) 2015 F&B Factory. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, AddCardViewControllerDelegate {
  
  @IBOutlet weak var cardIdLabel: UILabel?
  @IBOutlet weak var removeCardButton: UIButton!
  @IBOutlet weak var addCardButton: UIButton!
  
  let defaults = NSUserDefaults.standardUserDefaults()
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    updateCardId()
  }
  
  @IBAction func removeCard() {
    let alert = UIAlertController(title: "Ta bort kortet?", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
    alert.addAction(UIAlertAction(title: "Ta bort", style: .Destructive, handler: { action in
      self.defaults.removeObjectForKey(AppSettings.Key.RikslunchenCardID.rawValue)
      self.defaults.synchronize()
      
      self.updateCardId()
    }))
    alert.addAction(UIAlertAction(title: "Avbryt", style: .Cancel, handler: nil))
    presentViewController(alert, animated: true, completion: nil)
  }
  
  func updateCardId() {
    let cardId = defaults.integerForKey(AppSettings.Key.RikslunchenCardID.rawValue)
    if (cardId > 0) {
      cardIdLabel?.text = String(cardId)
      removeCardButton.hidden = false
      addCardButton.hidden = true
    } else {
      cardIdLabel?.text = "-"
      removeCardButton.hidden = true
      addCardButton.hidden = false
    }
  }
  
  @IBAction func addNewCard() {
    let addCardViewController = storyboard?.instantiateViewControllerWithIdentifier("AddCardViewController") as AddCardViewController
    addCardViewController.delegate = self
    tabBarController?.presentViewController(addCardViewController, animated: true, completion: nil)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}
