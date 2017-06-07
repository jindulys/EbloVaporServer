//
//  CompanySourceController.swift
//  EbloVaporServer
//
//  Created by yansong li on 2017-06-05.
//
//

import Foundation
import HTTP
import Vapor
import VaporPostgreSQL

/// Controller for Company Source
final class CompanySourceController: ResourceRepresentable {
  
  /// Service to crawling blog.
  let blogCrawlingService: BlogCrawlingService = BlogCrawlingService()
  
  func addRoutes(drop: Droplet) {
    let base = drop.grouped("companysource")
    base.get("all", handler: getCompanySource)
    base.get("source", handler: companySourceWebPage)
  }
  
  /// Get test blogs
  func getCompanySource(request: Request) throws -> ResponseRepresentable {
    return try JSON(node: CompanySource.all().makeNode())
  }
  
  /// Get all articles
  func companySourceWebPage(request: Request) throws -> ResponseRepresentable {
    let companySource = try CompanySource.all()
    let companySourceNodes = try companySource.makeNode()
    return try drop.view.make("companysource", Node(node: ["sources" : companySourceNodes]))
  }
  
  func create(request: Request) throws -> ResponseRepresentable {
    var companySource = try request.companySource()
    try companySource.save()
    if let id = companySource.id?.int, id == 1 {
      print("We have new company source")
      // NOTE: We created companysource for the first time, we need to start our company parse service.
      self.blogCrawlingService.startService(automaticallySaveWhenCrawlingFinished: true)
    }
    return companySource
  }
  
  func show(request: Request, companySource: CompanySource) throws -> ResponseRepresentable {
    return companySource
  }
  
  func update(request: Request, companySource: CompanySource) throws -> ResponseRepresentable {
    let new = try request.companySource()
    var companySource = companySource
    companySource.companyDataURLString = new.companyDataURLString
    try companySource.save()
    if let id = companySource.id?.int, id == 1 {
      print("We have updated company source")
      self.blogCrawlingService.startService(automaticallySaveWhenCrawlingFinished: true)
    }
    return companySource
  }
  
  func delete(request: Request, companySource: CompanySource) throws -> ResponseRepresentable {
    try companySource.delete()
    return JSON([:])
  }
  
  func makeResource() -> Resource<CompanySource> {
    return Resource(
      index: getCompanySource,
      store: create,
      show: show,
      modify: update,
      destroy: delete
    )
  }
}

extension Request {
  func companySource() throws -> CompanySource {
    guard let json = json else {
      throw Abort.badRequest
    }
    return try CompanySource(node: json)
  }
}
