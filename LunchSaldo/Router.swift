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
  
  case getBalance(cardId: Int)
  case loginSession(username: Int, password: String)
  case getCardList(username: Int)
  case getTransactions(cardId: Int, from: Date, to: Date, records: Int, offset: Int)
  
  var method: Alamofire.HTTPMethod {
    switch self {
    case .getBalance, .loginSession, .getCardList, .getTransactions:
      return .post
    }
  }
  
  func asURLRequest() throws -> URLRequest {
    var urlRequest = URLRequest(url: URL(string: RikslunchenRouter.baseUrlString)!)
    
    // construct http body, soap xml
    var soapString: String? {
      let soapRequest = AEXMLDocument()
      let attributes = ["xmlns:xsi": "http://www.w3.org/2001/XMLSchema-instance", "xmlns:xsd": "http://www.w3.org/2001/XMLSchema", "xmlns:soap": "http://schemas.xmlsoap.org/soap/envelope/", "xmlns:urn": "urn:PhoneService"]
      let envelope = soapRequest.addChild(name: "soap:Envelope", attributes: attributes)
      envelope.addChild(name: "soap:Header")
      let body = envelope.addChild(name: "soap:Body")
      
      switch self {
        
      case .getBalance(let id):
        let getBalance = body.addChild(name: "urn:getBalance")
        getBalance.addChild(name: "cardNo", value: String(id))
        
      case .loginSession(let username, let password):
        let loginSession = body.addChild(name: "urn:login")
        loginSession.addChild(name: "username", value: String(username))
        loginSession.addChild(name: "password", value: password)
        
      case .getCardList(let username):
        let getCardList = body.addChild(name: "urn:getCardList")
        getCardList.addChild(name: "username", value: String(username))
        
      case .getTransactions(let cardId, let fromDate, let toDate, let numberOfRecords, let offset):
        let getTransactions = body.addChild(name: "urn:getTransactionsDetailsList")
        getTransactions.addChild(name: "cardId", value: String(cardId))
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        getTransactions.addChild(name: "fromDate", value: dateFormatter.string(from: fromDate))
        getTransactions.addChild(name: "toDate", value: dateFormatter.string(from: toDate))
        getTransactions.addChild(name: "offset", value: String(offset))
        getTransactions.addChild(name: "noOfTransactions", value: String(numberOfRecords))
      }

      return soapRequest.xmlCompact
    }
    
    // set http header
    urlRequest.setValue(RikslunchenRouter.authToken, forHTTPHeaderField: "Authorization")
    urlRequest.setValue("", forHTTPHeaderField: "SOAPAction")
    urlRequest.setValue("text/xml; charset=UTF-8", forHTTPHeaderField: "Content-Type")
    urlRequest.setValue("application/xml", forHTTPHeaderField: "Accept")
    urlRequest.httpMethod = method.rawValue
    
    if let soap = soapString {
      let soapLength = soap.characters.count
      urlRequest.setValue(String(soapLength), forHTTPHeaderField: "Content-Length")
      urlRequest.httpBody = soap.data(using: String.Encoding.utf8, allowLossyConversion: false)
    }
    
    return urlRequest
  }
}
