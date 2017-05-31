//
//  CompanyController.swift
//  EbloVaporServer
//
//  Created by yansong li on 2017-05-30.
//
//

import Foundation
import HTTP
import Vapor
import VaporPostgreSQL

/// Controller for Company
final class CompanyController: ResourceRepresentable {
  func addRoutes(drop: Droplet) {
    let base = drop.grouped("company")
    base.get("all", handler: getCompanys)
  }
  
  /// Get test blogs
  func getCompanys(request: Request) throws -> ResponseRepresentable {
    return try JSON(node: Company.all().makeNode())
  }
  
  func create(request: Request) throws -> ResponseRepresentable {
    var company = try request.compay()
    try company.save()
    return company
  }
  
  func show(request: Request, company: Company) throws -> ResponseRepresentable {
    return company
  }
  
  func makeResource() -> Resource<Company> {
    return Resource(
      index: getCompanys
    )
  }
}

extension Request {
  func compay() throws -> Company {
    guard let json = json else {
      throw Abort.badRequest
    }
    return try Company(node: json)
  }
}
