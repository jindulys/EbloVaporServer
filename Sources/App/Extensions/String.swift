//
//  String.swift
//  EbloVaporServer
//
//  Created by yansong li on 2017-05-25.
//
//

import Foundation

/// Regex
extension String {
  
  /// Match a pattern and return matched string.
  public func match(pattern: String) -> String {
    do {
      let regex = try NSRegularExpression(pattern: pattern,
                                          options: .caseInsensitive)
      let range = NSMakeRange(0, self.characters.count)
      let matchRange = regex.rangeOfFirstMatch(in: self, range: range)
      if matchRange.location != NSNotFound {
        let chars = Array(self.characters)
        return String(chars[matchRange.location..<matchRange.location+matchRange.length])
      } else {
        return ""
      }
    } catch {
      print("Can not initialize regex")
      return ""
    }
  }
}
