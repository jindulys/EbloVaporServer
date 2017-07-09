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
      let matchRange = regex.rangeOfFirstMatch(in: self, options: [], range: range)
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
  
  /// Return a random string.
  public static func randomString() -> String {
    let array = ["sky", "china", "test", "hello", "US",
                 "procrastinate", "root", "Apple", "iOS",
                 "machine", "waterloo", "glass", "night"]
    srandom(UInt32(time(nil)))
    let number = Int(arc4random() % 10)
    var ret = ""
    for _ in 0..<number {
      let index = Int(arc4random() % UInt32(array.count))
      let count = Int(arc4random() % 6)
      ret += array[index]*count
    }
    return ret
  }
}

func *(left: String, right: Int) -> String {
  guard right >= 0 else {
    return ""
  }
  var ret = ""
  for _ in 0..<right {
    ret += left
  }
  return ret
}
