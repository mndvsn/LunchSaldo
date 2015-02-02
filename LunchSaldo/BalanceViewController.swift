//
//  BalanceViewController.swift
//  LunchSaldo
//
//  Created by Martin Furuberg on 2015-01-21.
//  Copyright (c) 2015 F&B Factory. All rights reserved.
//

import UIKit
import Alamofire

class BalanceViewController: UITableViewController, AddCardholderViewControllerDelegate {
  
  @IBOutlet weak var balanceLabel: UILabel!
  @IBOutlet weak var topUpDateLabel: UILabel!
  @IBOutlet weak var lastUpdateLabel: UILabel!

  var cardID: Int?
  var shouldPresentSetupView: Bool = true
  unowned let defaults = NSUserDefaults.standardUserDefaults()
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    checkStoredCards()
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    if shouldPresentSetupView {
      showCardSetup()
    }
  }
  
  func checkStoredCards() {
    if (defaults.integerForKey(AppSettings.Key.RikslunchenCardID.rawValue) == 0) {
      cardID = nil
      balanceLabel.text = "-"
      topUpDateLabel.text = "-"
      lastUpdateLabel.text = "Inga kort sparade"
    } else {
      cardID = defaults.integerForKey(AppSettings.Key.RikslunchenCardID.rawValue)
      
      // card data is old, clean and force re-add
      if cardID != nil && defaults.integerForKey(AppSettings.Key.RikslunchenCardID.rawValue) == 0 {
        removeCard()
        return
      }
      
      shouldPresentSetupView = false
      
      let storedBalance = defaults.doubleForKey(AppSettings.Key.Balance.rawValue)
      if storedBalance < 80 {
        self.balanceLabel.textColor = SWColor(hexString: "#EB5A51")
      } else {
        self.balanceLabel.textColor = SWColor(hexString: "#36BACF")
      }
      
      balanceLabel.text = "\(storedBalance) kr"
      if let topUpDate = defaults.stringForKey(AppSettings.Key.TopUpDate.rawValue) {
        topUpDateLabel.text = topUpDate
      }
      
      if let updatedDate = (defaults.objectForKey(AppSettings.Key.LastUpdatedTime.rawValue) as? NSDate) {
        let localizedDate = NSDateFormatter.localizedStringFromDate(updatedDate, dateStyle: NSDateFormatterStyle.ShortStyle, timeStyle: .ShortStyle)
        lastUpdateLabel.text = "Senaste uppdatering: " + localizedDate
      } else {
        lastUpdateLabel.text = "Saldot behöver uppdateras"
        updateBalance()
      }
    }
  }
  
  func showCardSetup() {
    let addCardViewController = storyboard?.instantiateViewControllerWithIdentifier("AddCardholderViewController") as AddCardholderViewController
    addCardViewController.delegate = self
    tabBarController?.presentViewController(addCardViewController, animated: false, completion: nil)
  }
  
  @IBAction func attemptUpdate() {
    let lastUpdate = defaults.objectForKey(AppSettings.Key.LastUpdatedTime.rawValue) as? NSDate
    if cardID != nil && lastUpdate?.timeIntervalSinceDate(NSDate()) < -60 {
        updateBalance()
    } else {
      refreshControl?.endRefreshing()
    }
  }
  
  func updateBalance() {
    if let id = cardID {
      Alamofire.request(RikslunchenRouter.GetBalance(cardId: id))
        .response { (request, response, data, error) in
          // println(request)
          // println(response)
          if (error != nil) {
            println(error)
          } else {
            
            if let balanceData = RikslunchenParser.parseBalanceData(data as NSData) {
              self.balanceLabel.text = "\(balanceData.amount) kr"
              self.topUpDateLabel.text = balanceData.topUpDate
              
              if balanceData.amount < 80 {
                self.balanceLabel.textColor = SWColor(hexString: "#EB5A51")
              } else {
                self.balanceLabel.textColor = SWColor(hexString: "#36BACF")
              }
              
              let newDate = NSDate()
              self.defaults.setObject(newDate, forKey: AppSettings.Key.LastUpdatedTime.rawValue)
              self.defaults.setObject(balanceData.topUpDate, forKey: AppSettings.Key.TopUpDate.rawValue)
              self.defaults.setObject(balanceData.amount, forKey: AppSettings.Key.Balance.rawValue)
              self.defaults.synchronize()
              
              let localizedDate = NSDateFormatter.localizedStringFromDate(newDate, dateStyle: NSDateFormatterStyle.ShortStyle, timeStyle: .ShortStyle)
              self.lastUpdateLabel.text = "Senaste uppdatering: " + localizedDate
            }
          }
          
          self.refreshControl?.endRefreshing()
      }
    }
  }
  
  func didUpdateCards() {
    checkStoredCards()
//    updateBalance()
  }
  
  func removeCard() {
    self.defaults.removeObjectForKey(AppSettings.Key.RikslunchenCardID.rawValue)
    self.defaults.removeObjectForKey(AppSettings.Key.Balance.rawValue)
    self.defaults.removeObjectForKey(AppSettings.Key.LastUpdatedTime.rawValue)
    self.defaults.removeObjectForKey(AppSettings.Key.TopUpDate.rawValue)
    self.defaults.removeObjectForKey(AppSettings.Key.Employer.rawValue)
    self.defaults.synchronize()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Table view
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    switch indexPath.row {
    case 1:
      return 40
    default:
      return tableView.bounds.size.height - 40
    }
  }
}
