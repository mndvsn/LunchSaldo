//
//  RikslunchenParser.swift
//  LunchSaldo
//
//  Created by Martin Furuberg on 2015-01-28.
//  Copyright (c) 2015 F&B Factory. All rights reserved.
//

import Foundation

class RikslunchenParser {
  
  class func parseBalanceData(data: NSData) -> (amount: Double, topUpDate: String)? {
    var error: NSError?
    if let xmlDoc = AEXMLDocument(xmlData: data as NSData, error: &error) {
      let amount = xmlDoc.root["soap:Body"]["ns2:getBalanceResponse"]["return"]["amount"].doubleValue
      let lastTopUpDate = xmlDoc.root["soap:Body"]["ns2:getBalanceResponse"]["return"]["lastTopUpDate"].stringValue
      
      return (amount, lastTopUpDate)
    }
    return nil
  }

  class func parseLoginResponseData(data: NSData) -> (Bool, String?) {
    var error: NSError?
    if let xmlDoc = AEXMLDocument(xmlData: data as NSData, error: &error) {
      println(xmlDoc.xmlString)
      if xmlDoc.root["soap:Body"]["ns2:loginResponse"]["return"].boolValue == false {
        return (false, "Felaktiga inloggningsuppgifter. Vänligen kontrollera användarnamn och lösenord och försök igen.")
      }
    }
    return (true, nil)
  }
  
  class func parseCardListResponseData(data: NSData) -> (cardId:Int, employerName:String)? {
    var error: NSError?
    if let xmlDoc = AEXMLDocument(xmlData: data as NSData, error: &error) {
      println(xmlDoc.xmlString)
      
      let cardId = xmlDoc.root["soap:Body"]["ns2:getCardListResponse"]["return"]["cardNo"].intValue
      let employerName = xmlDoc.root["soap:Body"]["ns2:getCardListResponse"]["return"]["employerName"].stringValue
      
      return (cardId, employerName)
    }
    return nil
  }
  
  class func parseCardValidationData(data: NSData) -> (Bool, String) {
    var error: NSError?
    if let xmlDoc = AEXMLDocument(xmlData: data as NSData, error: &error) {
      if xmlDoc.root["soap:Body"]["soap:Fault"].all?.count > 0 {
        return (false, xmlDoc.root["soap:Body"]["soap:Fault"]["faultstring"].stringValue)
      }
    }
    return (true, "")
  }
  
}