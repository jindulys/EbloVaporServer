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
          if let companyName1 = object1["company"], case let .string(name1) = companyName1,
            let companyName2 = object2["company"], case let .string(name2) = companyName2,
            name1 != name2 {
            return name1 < name2
          } else if let publishInterval1 = object1["publishdateinterval"],
            case let .number(date1) = publishInterval1,
            case let .double(double1) = date1,
            let publishInterval2 = object2["publishdateinterval"],
            case let .number(date2) = publishInterval2,
            case let .double(double2) = date2 {
            return double1 > double2
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
