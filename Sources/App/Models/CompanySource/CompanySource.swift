//
//  CompanySource.swift
//  EbloVaporServer
//
//  Created by yansong li on 2017-06-05.
//
//

import Foundation
import Vapor

/// Company source object.
public final class CompanySource: Model {
  
  public var id: Node?
  
  public var exists: Bool = false
  
  /// The company data url string.
  public var companyDataURLString: String
  
  public init(node: Node, in context: Context) throws {
    id = try node.extract("id")
    companyDataURLString = try node.extract("companydataurlstring")
  }
  
  public init(companyDataURLString: String) {
    self.companyDataURLString = companyDataURLString
    self.id = nil
  }
  
  public func makeNode(context: Context) throws -> Node {
    return try Node(node: [
      "id" : id,
      "companydataurlstring" : companyDataURLString])
  }
  
  public static func prepare(_ database: Database) throws {
    try database.create("companysources", closure: { companys in
      companys.id()
      companys.string("companydataurlstring")
    })
  }
  
  public static func revert(_ database: Database) throws {
    try database.delete("companysources")
  }
}
