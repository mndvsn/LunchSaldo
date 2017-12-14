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
  
  class func parseBalanceData(_ data: Data) -> (amount: Double, topUpDate: String)? {
    do {
      let xmlDoc = try AEXMLDocument(xml: data)
      let amount = xmlDoc.root["soap:Body"]["ns2:getBalanceResponse"]["return"]["amount"].double ?? 0.00
      let lastTopUpDate = xmlDoc.root["soap:Body"]["ns2:getBalanceResponse"]["return"]["lastTopUpDate"].string
      
      return (amount, lastTopUpDate)
    } catch {
      print("\(error)")
    }
    return nil
  }

  class func parseLoginResponseData(_ data: Data) -> (Bool, String?) {
    do {
      let xmlDoc = try AEXMLDocument(xml: data)
      // print(xmlDoc.xmlString)
      if xmlDoc.root["soap:Body"]["ns2:loginResponse"]["return"].bool == false {
        return (false, "Felaktiga inloggningsuppgifter. Vänligen kontrollera användarnamn och lösenord och försök igen.")
      }
    } catch {
      print("\(error)")
    }
    return (true, nil)
  }
  
  class func parseCardListResponseData(_ data: Data) -> (cardId:Int, employerName:String)? {
    do {
      let xmlDoc = try AEXMLDocument(xml: data)
//      println(xmlDoc.xmlString)
      
//      if xmlDoc.root["soap:Body"]["soap:Fault"].all?.count > 0 {
//        return (false, xmlDoc.root["soap:Body"]["soap:Fault"]["faultstring"].stringValue)
//      }
      
      let cardId = xmlDoc.root["soap:Body"]["ns2:getCardListResponse"]["return"]["cardNo"].int ?? 0
      let employerName = xmlDoc.root["soap:Body"]["ns2:getCardListResponse"]["return"]["employerName"].string
      
      return (cardId, employerName)
    } catch {
      print("\(error)")
    }
    return nil
  }
  
  class func parseTransactions(_ data: Data) -> ([Transaction]?) {
    do {
      let xmlDoc = try AEXMLDocument(xml: data)
      var transactions = [Transaction]()
      if let records = xmlDoc.root["soap:Body"]["ns2:getTransactionsDetailsListResponse"]["return"].all {
        for record in records {
          let amount = record["amount"].double ?? 0.0
          let date = record["date"].string
          
          var state: TransactionState {
            switch record["state"].string {
            case "FAILED":
              return .failed
            default: // "SUCCESSFUL"
              return .successful
            }
          }
          
          var type: TransactionType {
            switch record["type"].string {
            case "RELOAD":
              return .reload
            default: // "PURCHASE"
              return .purchase
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
