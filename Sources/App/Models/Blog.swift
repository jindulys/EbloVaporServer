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
  var urlString: String
  
  /// Blog's company name.
  var companyName: String
  
  /// the author name.
  var authorName: String
  
  /// the author avatar url.
  var authorAvatar: String
  
  /// the publish date.
  var publishDate: String
  
  init(node: Node, in context: Context) throws {
    id = try node.extract("id")
    title = try node.extract("title")
    urlString = try node.extract("urlstring")
    companyName = try node.extract("company")
    authorName = try node.extract("authorname")
    authorAvatar = try node.extract("authoravatar")
    publishDate = try node.extract("publishdate")
  }
  
  init(title: String,
       urlString: String,
       companyName: String,
       authorName: String = "",
       authorAvatar: String = "",
       publishDate: String = "") {
    self.title = title
    self.urlString = urlString
    self.companyName = companyName
    self.id = nil
    self.authorAvatar = authorAvatar
    self.authorName = authorName
    self.publishDate = publishDate
  }
  
  // MARK: JSONRepresentable
  func makeNode(context: Context) throws -> Node {
    return try Node(node:[
        "id" : id,
        "title" : title,
        "urlstring" : urlString,
        "company" : companyName,
        "authorname" : authorName,
        "authoravatar" : authorAvatar,
        "publishdate" : publishDate
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
