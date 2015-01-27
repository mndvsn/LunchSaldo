//
//  AddCardViewController.swift
//  LunchSaldo
//
//  Created by Martin Furuberg on 2015-01-22.
//  Copyright (c) 2015 F&B Factory. All rights reserved.
//

import UIKit
import Alamofire

@objc protocol AddCardViewControllerDelegate {
  optional func didUpdateCards()
}

class AddCardViewController: UIViewController, UITextFieldDelegate {
  
  @IBOutlet weak var cardTextfield: UITextField!
  @IBOutlet weak var saveButton: UIButton!
  
  var delegate: AddCardViewControllerDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 50))
    toolbar.items = [UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil), UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "done")]
    
    cardTextfield.inputAccessoryView = toolbar
    saveButton.enabled = false
  }
  
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    let newLength = countElements(textField.text!) + countElements(string) - range.length
    saveButton.enabled = (newLength >= AppSettings.Card.cardIdLength)
    return newLength <= AppSettings.Card.cardIdLength
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
  func done() {
    cardTextfield.resignFirstResponder()
  }
  
  @IBAction func validateAndSave() {
    saveButton.enabled = false
    if let id = cardTextfield.text.toInt() {
      if countElements(String(id)) == 8 {
        validateCardId(id)
      }
    }
  }
  
  func validateCardId(id:Int) {
    Alamofire.request(RikslunchenRouter.GetBalance(cardId: id)).response { (_, _, data, error) in
      
      let (isValid, errorString) = self.parseData(data as NSData)
      
      if (!isValid || error != nil) {
        self.saveButton.enabled = true
        let alert = UIAlertView(title: "Fel", message: errorString, delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "OK")
        alert.show()
      } else {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(id, forKey: AppSettings.Key.RikslunchenCardID.rawValue)
        
        // move back last updated time to enable updates
        defaults.setObject(NSDate(timeIntervalSinceNow: -1000), forKey: AppSettings.Key.LastUpdatedTime.rawValue)
        
        defaults.synchronize()
        self.delegate?.didUpdateCards?()
        
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
      }
    }
  }
  
  func parseData(data: NSData) -> (Bool, String) {
    var error: NSError?
    if let xmlDoc = AEXMLDocument(xmlData: data as NSData, error: &error) {
      println(xmlDoc.xmlString)
      if xmlDoc.root["soap:Body"]["soap:Fault"].all?.count > 0 {
        return (false, xmlDoc.root["soap:Body"]["soap:Fault"]["faultstring"].stringValue)
      }
    }
    return (true, "")
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}
