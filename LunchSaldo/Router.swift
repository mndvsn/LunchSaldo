//
//  Router.swift
//  LunchSaldo
//
//  Created by Martin Furuberg on 2015-01-22.
//  Copyright (c) 2015 F&B Factory. All rights reserved.
//

import Foundation
import Alamofire
import AEXML

enum RikslunchenRouter: URLRequestConvertible {
  static let baseUrlString = "https://www.rikslunchen.se/rkchws/PhoneService"
  static let authToken = "basic Q0g6ODlAUHFqJGw4NyMjTVM="
  
  case GetBalance(cardId: Int)
  case LoginSession(username: Int, password: String)
  case GetCardList(username: Int)
  case GetTransactions(cardId: Int, from: NSDate, to: NSDate, records: Int, offset: Int)
  
  var method: Alamofire.Method {
    switch self {
    case .GetBalance, .LoginSession, .GetCardList, .GetTransactions:
      return .POST
    }
  }
  
  var URLRequest: NSMutableURLRequest {
    let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: RikslunchenRouter.baseUrlString)!)
    
    // construct http body, soap xml
    var soapString: String? {
      let soapRequest = AEXMLDocument()
      let attributes = ["xmlns:xsi": "http://www.w3.org/2001/XMLSchema-instance", "xmlns:xsd": "http://www.w3.org/2001/XMLSchema", "xmlns:soap": "http://schemas.xmlsoap.org/soap/envelope/", "xmlns:urn": "urn:PhoneService"]
      let envelope = soapRequest.addChild(name: "soap:Envelope", attributes: attributes)
      envelope.addChild(name: "soap:Header")
      let body = envelope.addChild(name: "soap:Body")
      
      switch self {
        
      case .GetBalance(let id):
        let getBalance = body.addChild(name: "urn:getBalance")
        getBalance.addChild(name: "cardNo", value: String(id))
        
      case .LoginSession(let username, let password):
        let loginSession = body.addChild(name: "urn:login")
        loginSession.addChild(name: "username", value: String(username))
        loginSession.addChild(name: "password", value: password)
        
      case .GetCardList(let username):
        let getCardList = body.addChild(name: "urn:getCardList")
        getCardList.addChild(name: "username", value: String(username))
        
      case .GetTransactions(let cardId, let fromDate, let toDate, let numberOfRecords, let offset):
        let getTransactions = body.addChild(name: "urn:getTransactionsDetailsList")
        getTransactions.addChild(name: "cardId", value: String(cardId))
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        getTransactions.addChild(name: "fromDate", value: dateFormatter.stringFromDate(fromDate))
        getTransactions.addChild(name: "toDate", value: dateFormatter.stringFromDate(toDate))
        getTransactions.addChild(name: "offset", value: String(offset))
        getTransactions.addChild(name: "noOfTransactions", value: String(numberOfRecords))
      }

      return soapRequest.xmlString
    }
    
    // set http header
    mutableURLRequest.setValue(RikslunchenRouter.authToken, forHTTPHeaderField: "Authorization")
    mutableURLRequest.setValue("", forHTTPHeaderField: "SOAPAction")
    mutableURLRequest.setValue("text/xml; charset=UTF-8", forHTTPHeaderField: "Content-Type")
    mutableURLRequest.setValue("application/xml", forHTTPHeaderField: "Accept")
    mutableURLRequest.HTTPMethod = method.rawValue
    
    if let soap = soapString {
      let soapLength = soap.characters.count
      mutableURLRequest.setValue(String(soapLength), forHTTPHeaderField: "Content-Length")
      mutableURLRequest.HTTPBody = soap.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
    }
    
    return mutableURLRequest
  }
}