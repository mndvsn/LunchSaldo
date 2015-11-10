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
      let newLength = textField.text!.characters.count + string.characters.count - range.length
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
    if let username = Int(usernameInput.text!) {
      if String(username).characters.count == AppSettings.Card.usernameLength {
        let password = passwordInput.text!
        validateCardholder(username, password)
      }
    }
  }
  
  func validateCardholder(username:Int, _ password:String) {
    Alamofire.request(RikslunchenRouter.LoginSession(username: username, password: password)).response { (_, _, data, error) in

      if let loginData = data {
        var (valid, errorMessage) = RikslunchenParser.parseLoginResponseData(loginData)

        if valid && error == nil {
          self.getCardList(username)
        } else {
          self.saveButton.enabled = true

          if error != nil {
            errorMessage = "Det gick inte att ansluta. Kontrollera dina nätverksinställningar."
          }

          let alert = UIAlertController(title: "Fel", message: errorMessage, preferredStyle: .Alert)
          alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
          self.presentViewController(alert, animated: true, completion: nil)
        }
      }
    }
  }
  
  func getCardList(username: Int) {
    Alamofire.request(RikslunchenRouter.GetCardList(username: username))
      .response { (_, _, data, error) in
        if let cardListInfo = RikslunchenParser.parseCardListResponseData(data!) {
          self.defaults.setInteger(cardListInfo.cardId, forKey: AppSettings.Key.RikslunchenCardID.rawValue)
          self.defaults.setObject(NSString(UTF8String: cardListInfo.employerName), forKey: AppSettings.Key.Employer.rawValue)
          
          self.defaults.synchronize()
          
          self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
          
          self.delegate?.didUpdateCards?()
        }
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}
