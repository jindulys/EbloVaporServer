//
//  BlogMetaInfo.swift
//  EbloVaporServer
//
//  Created by yansong li on 2017-04-24.
//
//

import Foundation

/// A struct stores all kinds of meta data about a eng website.
public struct BlogMetaInfo {
  
  /// XPath to next page.
  public var nextPageXPath: String?
  
  /// Whether or not need to remove extra blog for next page url.
  public var needRemoveExtraBlog: Bool?
  
  /// Whether or not need to remove end slash.
  public var needRemoveEndSlash: Bool?
}
