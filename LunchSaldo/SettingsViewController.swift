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
  
  unowned let defaults = UserDefaults.standard
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let label = versionLabel {
      if let bundleInfo = Bundle.main.infoDictionary {
        let productName = bundleInfo[kCFBundleNameKey as String]!
        let productBuild = bundleInfo[kCFBundleVersionKey as String]!
        let productVersion = bundleInfo["CFBundleShortVersionString"] as! String
        
        label.text = "\(productName) \(productVersion) build \(productBuild)"
      }
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: true)
    updateCardData()
  }
  
  @IBAction func removeCard() {
    let alert = UIAlertController(title: "Ta bort kortet?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: "Ta bort", style: .destructive, handler: { action in
      self.defaults.removeObject(forKey: AppSettings.Key.RikslunchenCardID.rawValue)
      self.defaults.removeObject(forKey: AppSettings.Key.Balance.rawValue)
      self.defaults.removeObject(forKey: AppSettings.Key.LastUpdatedTime.rawValue)
      self.defaults.removeObject(forKey: AppSettings.Key.TopUpDate.rawValue)
      self.defaults.removeObject(forKey: AppSettings.Key.Employer.rawValue)
      self.defaults.synchronize()
      
      self.updateCardData()
    }))
    alert.addAction(UIAlertAction(title: "Avbryt", style: .cancel, handler: nil))
    UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
  }
  
  func updateCardData() {
    let cardId = defaults.integer(forKey: AppSettings.Key.RikslunchenCardID.rawValue)
    if (cardId > 0) {
      cardIdLabel.text = String(cardId)
      if let employerName = defaults.string(forKey: AppSettings.Key.Employer.rawValue) {
        employerLabel.text = employerName
      }
      
      removeCardButton.isHidden = false
      showTransactionsButton.isHidden = false
      addCardButton.isHidden = true
    } else {
      cardIdLabel.text = "-"
      employerLabel.text = "-"
      
      removeCardButton.isHidden = true
      showTransactionsButton.isHidden = true
      addCardButton.isHidden = false
    }
  }
  
  @IBAction func addNewCard() {
    let addCardViewController = storyboard?.instantiateViewController(withIdentifier: "AddCardholderViewController") as! AddCardholderViewController
    addCardViewController.delegate = self
    tabBarController?.present(addCardViewController, animated: true, completion: nil)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}
