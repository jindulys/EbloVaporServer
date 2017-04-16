//
//  Blog.swift
//  EbloVaporServer
//
//  Created by yansong li on 2017-04-16.
//
//

import Foundation
import Vapor

/// Class represents a blog.
final class Blog: Model {
  var id: Node?
  
  var exists: Bool = false
  
  /// Title for this blog.
  var title: String
  /// url string for this blog.
  var url_string: String
  /// Blog's company name
  var company_name: String
  
  init(node: Node, in context: Context) throws {
    id = try node.extract("id")
    title = try node.extract("title")
    url_string = try node.extract("urlstring")
    company_name = try node.extract("company")
  }
  
  init(title: String, urlString: String, companyName: String) {
    self.title = title
    self.url_string = urlString
    self.company_name = companyName
    self.id = nil
  }
  
  // MARK: JSONRepresentable
  func makeNode(context: Context) throws -> Node {
    return try Node(node:[
        "id" : id,
        "title" : title,
        "urlstring" : url_string,
        "company" : company_name,
      ])
  }
  
  // MARK: Model
  static func prepare(_ database: Database) throws {
    try database.create("blogs", closure: { blogs in
      blogs.id()
      blogs.string("title")
      blogs.string("urlstring")
      blogs.string("company")
    })
  }
  
  static func revert(_ database: Database) throws {
    try database.delete("blogs")
  }
}
