//
//  Unique.swift
//  EbloVaporServer
//
//  Created by yansong li on 2017-04-30.
//
//

import Foundation

/// Protocol for object with unique identifier.
public protocol Unique {
  associatedtype Key: CustomStringConvertible
  func identifier() -> Key
}

extension Unique {
  public func string() -> String {
    return String(describing: identifier())
  }
}


