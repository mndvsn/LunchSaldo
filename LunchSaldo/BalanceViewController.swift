//
//  BalanceViewController.swift
//  LunchSaldo
//
//  Created by Martin Furuberg on 2015-01-21.
//  Copyright (c) 2015 F&B Factory. All rights reserved.
//

import UIKit
import Alamofire

class BalanceViewController: UITableViewController, AddCardViewControllerDelegate {
  
  @IBOutlet weak var balanceLabel: UILabel!
  @IBOutlet weak var topUpDateLabel: UILabel!
  @IBOutlet weak var lastUpdateLabel: UILabel!
  
  var cardID: Int?
  var shouldPresentSetupView: Bool = true
  let defaults = NSUserDefaults.standardUserDefaults()
  
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
      balanceLabel.text = "-"
      topUpDateLabel.text = "-"
    } else {
      cardID = defaults.integerForKey(AppSettings.Key.RikslunchenCardID.rawValue)
      shouldPresentSetupView = false
      
      let storedBalance = defaults.doubleForKey(AppSettings.Key.Balance.rawValue)
      if storedBalance < 80 {
        self.balanceLabel.textColor = SWColor(hexString: "#EB5A51")
      } else {
        self.balanceLabel.textColor = SWColor(hexString: "#36BACF")
      }
      
      balanceLabel.text = "\(storedBalance) kr"
      topUpDateLabel.text = defaults.stringForKey(AppSettings.Key.TopUpDate.rawValue)
      
      let updatedDate = defaults.objectForKey(AppSettings.Key.LastUpdatedTime.rawValue) as NSDate
      let localizedDate = NSDateFormatter.localizedStringFromDate(updatedDate, dateStyle: NSDateFormatterStyle.ShortStyle, timeStyle: .ShortStyle)
      lastUpdateLabel.text = "Senaste uppdatering: " + localizedDate
      
      //attemptUpdate()
    }
  }
  
  func showCardSetup() {
    let addCardViewController = storyboard?.instantiateViewControllerWithIdentifier("AddCardViewController") as AddCardViewController
    addCardViewController.delegate = self
    tabBarController?.presentViewController(addCardViewController, animated: true, completion: nil)
  }
  
  @IBAction func attemptUpdate() {
    if let lastUpdate = defaults.objectForKey(AppSettings.Key.LastUpdatedTime.rawValue) as? NSDate {
      if lastUpdate.timeIntervalSinceDate(NSDate()) < -60 {
        updateBalance()
      } else {
        refreshControl?.endRefreshing()
      }
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
            if let balanceData = self.parseBalanceData(data as NSData) {
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
  
  func parseBalanceData(data: NSData) -> (amount: Double, topUpDate: String)? {
    var error: NSError?
    if let xmlDoc = AEXMLDocument(xmlData: data as NSData, error: &error) {
//      println(xmlDoc.xmlString)
      let amount = xmlDoc.root["soap:Body"]["ns2:getBalanceResponse"]["return"]["amount"].doubleValue
      let lastTopUpDate = xmlDoc.root["soap:Body"]["ns2:getBalanceResponse"]["return"]["lastTopUpDate"].stringValue
      
      return (amount, lastTopUpDate)
    }
    return nil
  }
  
  func didUpdateCards() {
    checkStoredCards()
    updateBalance()
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
