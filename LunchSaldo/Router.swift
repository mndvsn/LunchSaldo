//
//  Router.swift
//  LunchSaldo
//
//  Created by Martin Furuberg on 2015-01-22.
//  Copyright (c) 2015 F&B Factory. All rights reserved.
//

import Foundation
import Alamofire

enum RikslunchenRouter: URLRequestConvertible {
  static let baseUrlString = "https://www.rikslunchen.se/rkchws/PhoneService"
  static let authToken = "basic Q0g6ODlAUHFqJGw4NyMjTVM="
  
  case GetBalance(cardId: Int)
  
  var method: Alamofire.Method {
    switch self {
    case .GetBalance:
      return .POST
    }
  }
  
  var URLRequest: NSURLRequest {
    let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: RikslunchenRouter.baseUrlString)!)
    
    // construct http body, soap xml
    var soapString: String? {
      let soapRequest = AEXMLDocument()
      let attributes = ["xmlns:i": "http://www.w3.org/2001/XMLSchema-instance", "xmlns:d": "http://www.w3.org/2001/XMLSchema", "xmlns:c": "http://schemas.xmlsoap.org/soap/encoding/", "xmlns:v": "http://schemas.xmlsoap.org/soap/envelope/"]
      let envelope = soapRequest.addChild(name: "v:Envelope", attributes: attributes)
      let header = envelope.addChild(name: "v:Header")
      let body = envelope.addChild(name: "v:Body")
      
      switch self {
      case .GetBalance(let id):
        let getBalance = body.addChild(name: "n0:getBalance", attributes: ["id": "o0", "c:root": "1", "xmlns:n0": "urn:PhoneService"])
        getBalance.addChild(name: "cardNo", stringValue: String(id), attributes: ["i:type": "d:string"])
      }
      
      return soapRequest.xmlStringCompact
    }
    
    // set http header
    mutableURLRequest.setValue(RikslunchenRouter.authToken, forHTTPHeaderField: "Authorization")
    mutableURLRequest.setValue("", forHTTPHeaderField: "SOAPAction")
    mutableURLRequest.setValue("text/xml; charset=UTF-8", forHTTPHeaderField: "Content-Type")
    mutableURLRequest.HTTPMethod = method.rawValue
    
    if let soap = soapString {
      let soapLength = countElements(soap)
      mutableURLRequest.setValue(String(soapLength), forHTTPHeaderField: "Content-Length")
      mutableURLRequest.HTTPBody = soap.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
    }
    
    return mutableURLRequest
  }
}