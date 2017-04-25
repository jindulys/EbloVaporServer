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
  
  /// Blog's company name.
  var company_name: String
  
  /// the author name.
  var author_name: String
  
  /// the author avatar url.
  var author_avatar: String
  
  /// the publish date.
  var publish_date: String
  
  init(node: Node, in context: Context) throws {
    id = try node.extract("id")
    title = try node.extract("title")
    url_string = try node.extract("urlstring")
    company_name = try node.extract("company")
    author_name = try node.extract("authorname")
    author_avatar = try node.extract("authoravatar")
    publish_date = try node.extract("publishdate")
  }
  
  init(title: String,
       urlString: String,
       companyName: String,
       authorName: String = "",
       authorAvatar: String = "",
       publishDate: String = "") {
    self.title = title
    self.url_string = urlString
    self.company_name = companyName
    self.id = nil
    self.author_avatar = authorAvatar
    self.author_name = authorName
    self.publish_date = publishDate
  }
  
  // MARK: JSONRepresentable
  func makeNode(context: Context) throws -> Node {
    return try Node(node:[
        "id" : id,
        "title" : title,
        "urlstring" : url_string,
        "company" : company_name,
        "authorname" : author_name,
        "authoravatar" : author_avatar,
        "publishdate" : publish_date
      ])
  }
  
  // MARK: Model
  static func prepare(_ database: Database) throws {
    try database.create("blogs", closure: { blogs in
      blogs.id()
      blogs.string("title")
      blogs.string("urlstring")
      blogs.string("company")
      blogs.string("authorname", optional: true)
      blogs.string("authoravatar", optional: true)
      blogs.string("publishdate", optional: true)
    })
  }
  
  static func revert(_ database: Database) throws {
    try database.delete("blogs")
  }
}
