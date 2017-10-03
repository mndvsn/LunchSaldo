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
  @objc optional func didUpdateCards()
}

class AddCardholderViewController: UITableViewController, UITextFieldDelegate {
  
  @IBOutlet weak var usernameInput: UITextField!
  @IBOutlet weak var passwordInput: UITextField!
  @IBOutlet weak var saveButton: UIButton!
  
  weak var delegate: AddCardholderViewControllerDelegate?
  unowned let defaults = UserDefaults.standard
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.rowHeight = self.tableView.bounds.height
    saveButton.isEnabled = true
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    if textField == usernameInput {
      let newLength = textField.text!.characters.count + string.characters.count - range.length
      saveButton.isEnabled = (newLength >= AppSettings.Card.usernameLength)
      return newLength <= AppSettings.Card.usernameLength
    }
    return true
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
  @IBAction func validateAndSave() {
    saveButton.isEnabled = false
    if let username = Int(usernameInput.text!) {
      if String(username).characters.count == AppSettings.Card.usernameLength {
        let password = passwordInput.text!
        validateCardholder(username, password)
      }
    }
  }
  
  func validateCardholder(_ username:Int, _ password:String) {
    Alamofire.request(RikslunchenRouter.loginSession(username: username, password: password))
      .responseData { response in
        
        var errorMessage: String?
        
        switch response.result {
        case .success(let data):
          let (valid, err) = RikslunchenParser.parseLoginResponseData(data)
          if valid {
            return self.getCardList(username)
          } else {
            errorMessage = err
          }
          
        case .failure:
          self.saveButton.isEnabled = true
          errorMessage = "Det gick inte att ansluta. Kontrollera dina nätverksinställningar."
        }
        
        if let message = errorMessage {
          let alert = UIAlertController(title: "Fel", message: message, preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "OK", style: .default))
          self.present(alert, animated: true)
        }
    }
  }
  
  func getCardList(_ username: Int) {
    Alamofire.request(RikslunchenRouter.getCardList(username: username))
      .responseData { response in
        switch response.result {
        case .success(let data):
          if let cardListInfo = RikslunchenParser.parseCardListResponseData(data) {
            self.defaults.set(cardListInfo.cardId, forKey: AppSettings.Key.RikslunchenCardID.rawValue)
            self.defaults.set(NSString(utf8String: cardListInfo.employerName), forKey: AppSettings.Key.Employer.rawValue)
            
            self.defaults.synchronize()
            
            self.presentingViewController?.dismiss(animated: true)
            
            self.delegate?.didUpdateCards?()
          }
        default:
          break
        }
      }
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return self.tableView.frame.height
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}
