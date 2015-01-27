//
//  Constants.swift
//  LunchSaldo
//
//  Created by Martin Furuberg on 2015-01-23.
//  Copyright (c) 2015 F&B Factory. All rights reserved.
//

import Foundation

struct AppSettings {
  struct Card {
    static let cardIdLength = 8
  }
  
  enum Key: String {
    case RikslunchenCardID = "rikslunchenCardID"
    case Balance = "balance"
    case TopUpDate = "topUpDate"
    case LastUpdatedTime = "lastUpdated"
  }
}