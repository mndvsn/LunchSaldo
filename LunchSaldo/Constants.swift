//
//  Constants.swift
//  LunchSaldo
//
//  Created by Martin Furuberg on 2015-01-23.
//  Copyright (c) 2015 F&B Factory. All rights reserved.
//

import Foundation
import SwiftColors

struct AppSettings {
  struct Card {
    static let cardIdLength = 8
    static let usernameLength = 12
  }
  
  enum Key: String {
    case RikslunchenCardID = "rikslunchenCardID"
    case Balance = "balance"
    case TopUpDate = "topUpDate"
    case LastUpdatedTime = "lastUpdated"
    case Employer = "employer"
  }
  
  struct Color {
    static let red = UIColor(hex: 0xEB5A51)
    static let blue = UIColor(hex: 0x36BACF)
  }
}