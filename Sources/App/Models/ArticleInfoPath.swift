//
//  ArticleInfoPath.swift
//  EbloVaporServer
//
//  Created by yansong li on 2017-04-24.
//
//

import Foundation

/// A struct that stores XPaths to all kinds of information about an article.
public struct ArticleInfoPath {
  
  /// XPath to article title.
  public let title: String
  
  /// XPath to href.
  public let href: String
  
  /// XPath to author name.
  public var authorName: String?
  
  /// XPath to author avatar.
  public var authorAvatar: String?
  
  /// XPath to publish date.
  public var publishDate: String?
  
  init(title: String,
       href: String,
       authorName: String? = nil,
       authorAvatar: String? = nil,
       publishDate: String? = nil) {
    self.title = title
    self.href = href
    self.authorName = authorName
    self.authorAvatar = authorAvatar
    self.publishDate = publishDate
  }
}
