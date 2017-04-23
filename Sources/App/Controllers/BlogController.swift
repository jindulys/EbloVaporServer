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
final class BlogController {
  
  func addRoutes(drop: Droplet) {
    let base = drop.grouped("blog")
    base.get("article", handler: articleWebPage)
    base.get("test", handler: getBlogs)
  }
  
  /// Get all articles
  func articleWebPage(request: Request) throws -> ResponseRepresentable {
    let articles = try Blog.all().map({ blog in
      return blog.title
    }).filter { (tilte) -> Bool in
      return tilte.characters.count > 10
    }
    let articleNodes = try articles.makeNode()
    return try drop.view.make("article", Node(node: ["articles" : articleNodes]))
  }
  
  /// Get test blogs
  func getBlogs(request: Request) throws -> ResponseRepresentable {
    return try JSON(node: Blog.all().makeNode())
  }
}
