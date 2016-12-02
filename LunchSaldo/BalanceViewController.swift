//
//  BalanceViewController.swift
//  LunchSaldo
//
//  Created by Martin Furuberg on 2015-01-21.
//  Copyright (c) 2015 F&B Factory. All rights reserved.
//

import UIKit
import Alamofire
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class BalanceViewController: UITableViewController, AddCardholderViewControllerDelegate {
  
  @IBOutlet weak var balanceLabel: UILabel!
  @IBOutlet weak var topUpDateLabel: UILabel!
  @IBOutlet weak var lastUpdateLabel: UILabel!

  var cardID: Int?
  var shouldPresentSetupView: Bool = true
  unowned let defaults = UserDefaults.standard
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    checkStoredCards()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if shouldPresentSetupView {
      showCardSetup()
    }
  }
  
  func checkStoredCards() {
    if (defaults.integer(forKey: AppSettings.Key.RikslunchenCardID.rawValue) == 0) {
      cardID = nil
      balanceLabel.text = "-"
      topUpDateLabel.text = "-"
      lastUpdateLabel.text = "Inga kort sparade"
    } else {
      cardID = defaults.integer(forKey: AppSettings.Key.RikslunchenCardID.rawValue)
      
      // card data is old, clean and force re-add
      if cardID != nil && defaults.integer(forKey: AppSettings.Key.RikslunchenCardID.rawValue) == 0 {
        removeCard()
        return
      }
      
      shouldPresentSetupView = false
      
      let storedBalance = defaults.double(forKey: AppSettings.Key.Balance.rawValue)
      if storedBalance < 80 {
        self.balanceLabel.textColor = AppSettings.Color.red!
      } else {
        self.balanceLabel.textColor = AppSettings.Color.blue!
      }
      
      balanceLabel.text = "\(storedBalance) kr"
      if let topUpDate = defaults.string(forKey: AppSettings.Key.TopUpDate.rawValue) {
        topUpDateLabel.text = topUpDate
      }
      
      if let updatedDate = (defaults.object(forKey: AppSettings.Key.LastUpdatedTime.rawValue) as? Date) {
        let localizedDate = DateFormatter.localizedString(from: updatedDate, dateStyle: DateFormatter.Style.short, timeStyle: .short)
        lastUpdateLabel.text = "Senaste uppdatering: " + localizedDate
      } else {
        lastUpdateLabel.text = "Saldot behöver uppdateras"
        updateBalance()
      }
    }
  }
  
  func showCardSetup() {
    let addCardViewController = storyboard?.instantiateViewController(withIdentifier: "AddCardholderViewController") as! AddCardholderViewController
    addCardViewController.delegate = self
    tabBarController?.present(addCardViewController, animated: false, completion: nil)
  }
  
  @IBAction func attemptUpdate() {
    let lastUpdate = defaults.object(forKey: AppSettings.Key.LastUpdatedTime.rawValue) as? Date
    if cardID != nil && lastUpdate?.timeIntervalSince(Date()) < -60 {
        updateBalance()
    } else {
      refreshControl?.endRefreshing()
    }
  }
  
  func updateBalance() {
    if let id = cardID {
      Alamofire.request(RikslunchenRouter.getBalance(cardId: id))
        .responseData { response in
          switch response.result {
          case .success(let data):
            if let balanceData = RikslunchenParser.parseBalanceData(data) {
              self.balanceLabel.text = "\(balanceData.amount) kr"
              self.topUpDateLabel.text = balanceData.topUpDate
              
              if balanceData.amount < 80 {
                self.balanceLabel.textColor = AppSettings.Color.red!
              } else {
                self.balanceLabel.textColor = AppSettings.Color.blue!
              }
              
              let newDate = Date()
              self.defaults.set(newDate, forKey: AppSettings.Key.LastUpdatedTime.rawValue)
              self.defaults.set(balanceData.topUpDate, forKey: AppSettings.Key.TopUpDate.rawValue)
              self.defaults.set(balanceData.amount, forKey: AppSettings.Key.Balance.rawValue)
              self.defaults.synchronize()
              
              let localizedDate = DateFormatter.localizedString(from: newDate, dateStyle: .short, timeStyle: .short)
              self.lastUpdateLabel.text = "Senaste uppdatering: " + localizedDate
            }
            
          case .failure(let error):
            print(error)
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
    self.defaults.removeObject(forKey: AppSettings.Key.RikslunchenCardID.rawValue)
    self.defaults.removeObject(forKey: AppSettings.Key.Balance.rawValue)
    self.defaults.removeObject(forKey: AppSettings.Key.LastUpdatedTime.rawValue)
    self.defaults.removeObject(forKey: AppSettings.Key.TopUpDate.rawValue)
    self.defaults.removeObject(forKey: AppSettings.Key.Employer.rawValue)
    self.defaults.synchronize()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Table view
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch indexPath.row {
    case 1:
      return 40
    default:
      return tableView.bounds.size.height - 40
    }
  }
}
