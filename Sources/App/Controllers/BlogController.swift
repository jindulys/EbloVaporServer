//
//  BlogController.swift
//  EbloVaporServer
//
//  Created by yansong li on 2017-04-22.
//
//

import Foundation
import HTTP
import Vapor
import VaporPostgreSQL

/// Controller for Blog
final class BlogController: ResourceRepresentable {
  
  func addRoutes(drop: Droplet) {
    let base = drop.grouped("blog")
    base.get("article", handler: articleWebPage)
    base.get("test", handler: getBlogs)
  }
  
  /// Get all articles
  func articleWebPage(request: Request) throws -> ResponseRepresentable {
    let articles = try Blog.all()
    var articleNodes = try articles.makeNode()
    if case let .array(articleNodeArray) = articleNodes {
      // Sort article according to company and publish date.
      let sortedNodeArray = articleNodeArray.sorted { node1, node2 in
        switch (node1, node2) {
        case let (.object(object1), .object(object2)):
          if let companyName1 = object1["company"]?.string,
            let companyName2 = object2["company"]?.string,
            companyName1 != companyName2 {
            return companyName1 < companyName2
          } else if let publishInterval1 = object1["publishdateinterval"]?.double,
            let publishInterval2 = object2["publishdateinterval"]?.double {
            return publishInterval1 > publishInterval2
          }
        default:
          return true
        }
        return true
      }
      articleNodes = try sortedNodeArray.makeNode()
    }
    return try drop.view.make("article", Node(node: ["articles" : articleNodes]))
  }
  
  /// Get test blogs
  func getBlogs(request: Request) throws -> ResponseRepresentable {
    return try JSON(node: Blog.all().makeNode())
  }
  
  func create(request: Request) throws -> ResponseRepresentable {
    var blog = try request.blog()
    try blog.save()
    return blog
  }
  
  func show(request: Request, blog: Blog) throws -> ResponseRepresentable {
    return blog
  }
  
  func makeResource() -> Resource<Blog> {
    return Resource(
      index: getBlogs
    )
  }
}

extension Request {
  func blog() throws -> Blog {
    guard let json = json else {
      throw Abort.badRequest
    }
    return try Blog(node: json)
  }
}
