//
//  RikslunchenParser.swift
//  LunchSaldo
//
//  Created by Martin Furuberg on 2015-01-28.
//  Copyright (c) 2015 F&B Factory. All rights reserved.
//

import Foundation
import AEXML

class RikslunchenParser {
  
  class func parseBalanceData(data: NSData) -> (amount: Double, topUpDate: String)? {
    do {
      let xmlDoc = try AEXMLDocument(xmlData: data)
      let amount = xmlDoc.root["soap:Body"]["ns2:getBalanceResponse"]["return"]["amount"].doubleValue
      let lastTopUpDate = xmlDoc.root["soap:Body"]["ns2:getBalanceResponse"]["return"]["lastTopUpDate"].stringValue
      
      return (amount, lastTopUpDate)
    } catch {
      print("\(error)")
    }
    return nil
  }

  class func parseLoginResponseData(data: NSData) -> (Bool, String?) {
    do {
      let xmlDoc = try AEXMLDocument(xmlData: data)
      // print(xmlDoc.xmlString)
      if xmlDoc.root["soap:Body"]["ns2:loginResponse"]["return"].boolValue == false {
        return (false, "Felaktiga inloggningsuppgifter. Vänligen kontrollera användarnamn och lösenord och försök igen.")
      }
    } catch {
      print("\(error)")
    }
    return (true, nil)
  }
  
  class func parseCardListResponseData(data: NSData) -> (cardId:Int, employerName:String)? {
    do {
      let xmlDoc = try AEXMLDocument(xmlData: data)
//      println(xmlDoc.xmlString)
      
//      if xmlDoc.root["soap:Body"]["soap:Fault"].all?.count > 0 {
//        return (false, xmlDoc.root["soap:Body"]["soap:Fault"]["faultstring"].stringValue)
//      }
      
      let cardId = xmlDoc.root["soap:Body"]["ns2:getCardListResponse"]["return"]["cardNo"].intValue
      let employerName = xmlDoc.root["soap:Body"]["ns2:getCardListResponse"]["return"]["employerName"].stringValue
      
      return (cardId, employerName)
    } catch {
      print("\(error)")
    }
    return nil
  }
  
  class func parseTransactions(data: NSData) -> ([Transaction]?) {
    do {
      let xmlDoc = try AEXMLDocument(xmlData: data)
      var transactions = [Transaction]()
      if let records = xmlDoc.root["soap:Body"]["ns2:getTransactionsDetailsListResponse"]["return"].all {
        for record in records {
          let amount = record["amount"].doubleValue
          let date = record["date"].stringValue
          
          var state: TransactionState {
            switch record["state"].stringValue {
            case "FAILED":
              return .Failed
            default: // "SUCCESSFUL"
              return .Successful
            }
          }
          
          var type: TransactionType {
            switch record["type"].stringValue {
            case "RELOAD":
              return .Reload
            default: // "PURCHASE"
              return .Purchase
            }
          }
          transactions.append(Transaction(amount: amount, date: date, state: state, type: type))
        }
      }
      return transactions
    } catch {
      print("\(error)")
    }
    return nil
  }
  
}