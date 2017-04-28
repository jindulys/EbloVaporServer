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
    let articleNodes = try articles.makeNode()
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
