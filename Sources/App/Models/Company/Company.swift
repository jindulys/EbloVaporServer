//
//  File.swift
//  EbloVaporServer
//
//  Created by yansong li on 2017-05-30.
//
//

import Foundation
import Vapor

/// Class represents a company
public final class Company: Model {
  
  public var id: Node?
  
  public var exists: Bool = false
  
  /// Company name.
  public var companyName: String
  
  /// Company url string.
  public var companyUrlString: String
  
  public init(node: Node, in context: Context) throws {
    id = try node.extract("id")
    companyName = try node.extract("companyname")
    companyUrlString = try node.extract("companyurlstring")
  }
  
  public init(companyName: String,
              companyUrlString: String) {
    self.companyName = companyName
    self.companyUrlString = companyUrlString
    self.id = nil
  }
  
  public func makeNode(context: Context) throws -> Node {
    return try Node(node: [
        "id" : id,
        "companyname" : companyName,
        "companyurlstring" : companyUrlString
      ])
  }
  
  public static func prepare(_ database: Database) throws {
    try database.create("companys", closure: { companys in
      companys.id()
      companys.string("companyname")
      companys.string("companyurlstring")
    })
  }
  
  public static func revert(_ database: Database) throws {
    try database.delete("companys")
  }
}

extension Company: Unique {
  public func identifier() -> String {
    return self.companyName + self.companyUrlString
  }
}
