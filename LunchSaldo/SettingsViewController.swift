//
//  SettingsViewController.swift
//  LunchSaldo
//
//  Created by Martin Furuberg on 2015-01-22.
//  Copyright (c) 2015 F&B Factory. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, AddCardholderViewControllerDelegate {
  
  @IBOutlet weak var cardIdLabel: UILabel!
  @IBOutlet weak var employerLabel: UILabel!
  @IBOutlet weak var removeCardButton: UIButton!
  @IBOutlet weak var addCardButton: UIButton!
    @IBOutlet weak var showTransactionsButton: UIButton!
  
  @IBOutlet weak var versionLabel: UILabel?
  
  unowned let defaults = NSUserDefaults.standardUserDefaults()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let label = versionLabel {
      if let bundleInfo = NSBundle.mainBundle().infoDictionary? {
        let productName = bundleInfo[kCFBundleNameKey] as String
        let productBuild = bundleInfo[kCFBundleVersionKey] as String
        let productVersion = bundleInfo["CFBundleShortVersionString"] as String
        
        label.text = "\(productName) \(productVersion) build \(productBuild)"
      }
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: true)
    updateCardData()
  }
  
  @IBAction func removeCard() {
    let alert = UIAlertController(title: "Ta bort kortet?", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
    alert.addAction(UIAlertAction(title: "Ta bort", style: .Destructive, handler: { action in
      self.defaults.removeObjectForKey(AppSettings.Key.RikslunchenCardID.rawValue)
      self.defaults.removeObjectForKey(AppSettings.Key.Balance.rawValue)
      self.defaults.removeObjectForKey(AppSettings.Key.LastUpdatedTime.rawValue)
      self.defaults.removeObjectForKey(AppSettings.Key.TopUpDate.rawValue)
      self.defaults.removeObjectForKey(AppSettings.Key.Employer.rawValue)
      self.defaults.synchronize()
      
      self.updateCardData()
    }))
    alert.addAction(UIAlertAction(title: "Avbryt", style: .Cancel, handler: nil))
    UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
  }
  
  func updateCardData() {
    let cardId = defaults.integerForKey(AppSettings.Key.RikslunchenCardID.rawValue)
    if (cardId > 0) {
      cardIdLabel.text = String(cardId)
      if let employerName = defaults.stringForKey(AppSettings.Key.Employer.rawValue) {
        employerLabel.text = employerName
      }
      
      removeCardButton.hidden = false
      showTransactionsButton.hidden = false
      addCardButton.hidden = true
    } else {
      cardIdLabel.text = "-"
      employerLabel.text = "-"
      
      removeCardButton.hidden = true
      showTransactionsButton.hidden = true
      addCardButton.hidden = false
    }
  }
  
  @IBAction func addNewCard() {
    let addCardViewController = storyboard?.instantiateViewControllerWithIdentifier("AddCardholderViewController") as AddCardholderViewController
    addCardViewController.delegate = self
    tabBarController?.presentViewController(addCardViewController, animated: true, completion: nil)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}
