//
//  AddCardholderViewController.swift
//  LunchSaldo
//
//  Created by Martin Furuberg on 2015-01-22.
//  Copyright (c) 2015 F&B Factory. All rights reserved.
//

import UIKit
import Alamofire

@objc protocol AddCardholderViewControllerDelegate {
  optional func didUpdateCards()
}

class AddCardholderViewController: UITableViewController, UITextFieldDelegate {
  
  @IBOutlet weak var usernameInput: UITextField!
  @IBOutlet weak var passwordInput: UITextField!
  @IBOutlet weak var saveButton: UIButton!
  
  weak var delegate: AddCardholderViewControllerDelegate?
  unowned let defaults = NSUserDefaults.standardUserDefaults()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.rowHeight = self.tableView.bounds.height
    saveButton.enabled = false
  }
  
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    if textField == usernameInput {
      let newLength = countElements(textField.text!) + countElements(string) - range.length
      saveButton.enabled = (newLength >= AppSettings.Card.usernameLength)
      return newLength <= AppSettings.Card.usernameLength
    }
    return true
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
  @IBAction func validateAndSave() {
    saveButton.enabled = false
    if let username = usernameInput.text.toInt() {
      if countElements(String(username)) == AppSettings.Card.usernameLength {
        let password = passwordInput.text
        validateCardholder(username, password)
      }
    }
  }
  
  func validateCardholder(username:Int, _ password:String) {
    Alamofire.request(RikslunchenRouter.LoginSession(username: username, password: password)).response { (_, _, data, error) in
      
      let (valid, errorString) = RikslunchenParser.parseLoginResponseData(data as NSData)
      
      println("validate")
      
      if valid && error == nil {
        self.defaults.setInteger(username, forKey: AppSettings.Key.RikslunchenUsername.rawValue)
        // move back last updated time to enable updates
        self.defaults.setObject(NSDate(timeIntervalSinceNow: -1000), forKey: AppSettings.Key.LastUpdatedTime.rawValue)
        
        self.getCardList(username)
      } else {
        self.saveButton.enabled = true
        
        let alert = UIAlertController(title: "Fel", message: errorString!, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
      }
    }
  }
  
  func getCardList(username: Int) {
    Alamofire.request(RikslunchenRouter.GetCardList(username: username))
      .response { (_, _, data, error) in
        if let cardListInfo = RikslunchenParser.parseCardListResponseData(data as NSData) {
          
          self.defaults.setInteger(cardListInfo.cardId, forKey: AppSettings.Key.RikslunchenCardID.rawValue)
          self.defaults.setObject(NSString(UTF8String: cardListInfo.employerName), forKey: AppSettings.Key.Employer.rawValue)
          
          self.defaults.synchronize()
          self.delegate?.didUpdateCards?()
          
          self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}
