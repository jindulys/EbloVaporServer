//
//  DateTool.swift
//  EbloVaporServer
//
//  Created by yansong li on 2017-05-24.
//
//

import Foundation

/// A tool for handling all kinds of date related operation.
enum StringParsedDateComponents {
  
  static let monthPattern = "Jan(uary)?|Feb(ruary)?|Mar(ch)?|Apr(il)?|May|Jun(e)?|Jul(y)?|Aug(ust)?|Sep(tember)?|Oct(ober)?|Nov(ember)?|Dec(ember)?"
  
  static let dayPattern = "\\d{2}|\\d{1}"
  
  static let yearPattern = "\\d{4}"
  
  case Month(Int)
  
  case Day(Int)
  
  case Year(Int)
  
  case None
  
  /// Return first met month from a string
  static func month(from: String) -> StringParsedDateComponents {
    let matched = from.match(pattern: self.monthPattern)
    if matched != "" {
      switch matched {
      case "Jan", "January":
        return .Month(1)
      case "Feb", "February":
        return .Month(2)
      case "Mar", "March":
        return .Month(3)
      case "Apr", "April":
        return .Month(4)
      case "May":
        return .Month(5)
      case "Jun", "June":
        return .Month(6)
      case "Jul", "July":
        return .Month(7)
      case "Aug", "August":
        return .Month(8)
      case "Sep", "September":
        return .Month(9)
      case "Oct", "October":
        return .Month(10)
      case "Nov", "November":
        return .Month(11)
      case "Dec", "December":
        return .Month(12)
      default:
        return .None
      }
    }
    return .None
  }
  
  /// Return first met day from a string
  static func day(from: String) -> StringParsedDateComponents {
    let matched = from.match(pattern: self.dayPattern)
    if matched != "", let matchedInt = Int(matched) {
      return .Day(matchedInt)
    }
    return .None
  }
  
  /// Return first met year from a string
  static func year(from: String) -> StringParsedDateComponents {
    let matched = from.match(pattern: self.yearPattern)
    if matched != "", let matchedInt = Int(matched) {
      return .Year(matchedInt)
    }
    return .None
  }
}

extension StringParsedDateComponents: CustomDebugStringConvertible {
  var debugDescription: String {
    switch self {
    case let .Month(month):
      return "Month \(month)"
    case let .Day(day):
      return "Day \(day)"
    case let .Year(year):
      return "Year \(year)"
    case .None:
      return "None"
    }
  }
}

extension StringParsedDateComponents {
  // Generate a date from enumeration.
  static func dateFrom(year: StringParsedDateComponents,
                       month: StringParsedDateComponents,
                       day: StringParsedDateComponents) -> Date? {
    guard case let .Year(yearInt) = year,
      case let .Month(monthInt) = month,
      case let .Day(dayInt) = day else {
      return nil
    }
    let calendar = NSCalendar(identifier: .gregorian)
    var components = DateComponents()
    components.year = yearInt
    components.month = monthInt
    components.day = dayInt
    return calendar?.date(from: components)
  }
}
