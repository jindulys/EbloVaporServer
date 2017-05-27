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
public final class Blog: Model {
  public var id: Node?
  
  public var exists: Bool = false
  
  /// Title for this blog.
  public var title: String
  
  /// url string for this blog.
  public var urlString: String
  
  /// Blog's company name.
  public var companyName: String
  
  /// the author name.
  public var authorName: String
  
  /// the author avatar url.
  public var authorAvatar: String
  
  /// the publish date.
  public var publishDate: String
  
  /// The publish date time interval.
  public var publishDateInterval: Double
  
  public init(node: Node, in context: Context) throws {
    id = try node.extract("id")
    title = try node.extract("title")
    urlString = try node.extract("urlstring")
    companyName = try node.extract("company")
    authorName = try node.extract("authorname")
    authorAvatar = try node.extract("authoravatar")
    publishDate = try node.extract("publishdate")
    // Note: use all lower case for the key.
    if let interval = node["publishdateinterval"]?.double {
      publishDateInterval = interval
    } else {
      publishDateInterval = 0.0
    }
  }
  
  public init(title: String,
       urlString: String,
       companyName: String,
       authorName: String = "",
       authorAvatar: String = "",
       publishDate: String = "",
       publishDateInterval: Double = 0.0) {
    self.title = title
    self.urlString = urlString
    self.companyName = companyName
    self.id = nil
    self.authorAvatar = authorAvatar
    self.authorName = authorName
    self.publishDate = publishDate
    self.publishDateInterval = publishDateInterval
  }
  
  // MARK: JSONRepresentable
  public func makeNode(context: Context) throws -> Node {
    return try Node(node:[
        "id" : id,
        "title" : title,
        "urlstring" : urlString,
        "company" : companyName,
        "authorname" : authorName,
        "authoravatar" : authorAvatar,
        "publishdate" : publishDate,
        "publishdateinterval" : publishDateInterval
      ])
  }
  
  // MARK: Model
  public static func prepare(_ database: Database) throws {
    try database.create("blogs", closure: { blogs in
      blogs.id()
      blogs.string("title")
      blogs.string("urlstring")
      blogs.string("company")
      blogs.string("authorname", optional: true)
      blogs.string("authoravatar", optional: true)
      blogs.string("publishdate", optional: true)
      blogs.double("publishdateinterval", optional: true)
    })
  }
  
  public static func revert(_ database: Database) throws {
    try database.delete("blogs")
  }
}

extension Blog: Unique {
  public func identifier() -> String {
    return self.title + self.companyName
  }
}
