//
//  BlogParser.swift
//  EbloVaporServer
//
//  Created by yansong li on 2017-04-16.
//
//

import Foundation
import Kanna
import Utilities

/// This is a class used for parse a url.
public class BlogParser {
  
  /// The string to parse.
  public var baseURLString: String
  
  /// Whether or not be need the base url to composite a valid URL.
  public let basedOnBaseURL: Bool
  
  /// The companyName.
  public let companyName: String
  
  /// XPath infos for article.
  public let articlePath: ArticleInfoPath
  
  /// Meta data for article.
  public let metaData: BlogMetaInfo
  
  /// Array contains all the article titles founded.
  public private(set) var articles: [String] = []
  
  /// Array for articleURLs.
  public private(set) var articleURLs: [String] = []
  
  /// Array for publish dates.
  public private(set) var publishDates: [String] = []
  
  /// Array for author names.
  public private(set) var authorNames: [String] = []
  
  /// Array for author avatar urls.
  public private(set) var authorAvatarURLs: [String] = []
  
  /// Array for parse blog.
  public private(set) var Blogs: [Blog] = []
  
  /// The maximum depth for blog pagination.
  private let maxDepth: Int = 10
  
  /// Current depth has processed.
  private var currentDepth: Int = 0
  
  init(baseURLString: String,
       articlePath: ArticleInfoPath,
       metaData: BlogMetaInfo,
       companyName: String,
       basedOnBaseURL: Bool) {
    self.baseURLString = baseURLString
    self.articlePath = articlePath
    self.metaData = metaData
    self.companyName = companyName
    self.basedOnBaseURL = basedOnBaseURL
  }
  
  /// Parse this company's blog.
  public func parse() {
    self.parse(completion: nil)
  }
  
  public func parse(completion: ((Bool) -> ())?) {
    parse(url: self.baseURLString)
    print("Parse Finished, total found \(self.articles.count) aritcles")
    print("Parse Finished, total found \(self.articleURLs.count) article urls")
    print("Parse Finished, total found \(self.publishDates.count) dates")
    if let completion = completion {
      completion(true)
    }
  }
  
  // MARK: Priave
  /// Parse a URL.
  public func parse(url: String) {
    guard self.currentDepth < maxDepth else {
      print("Blog Parser has reached the max depth")
      return
    }
    
    guard let url = URL(string: url) else {
      print("Invalid url");
      return
    }
    guard let doc = HTML(url: url, encoding: .utf8) else {
      print("Invalid doc");
      return
    }
    
    var articles: [String] = []
    var articleURLs: [String] = []
    var publishDates: [String] = []
    var authorNames: [String] = []
    var authorAvatarURLs: [String] = []
    
    // 1. Find and print all title in current page.
    parse(doc: doc, xPath: self.articlePath.title) { title in
      print("Find article \(title)")
      articles.append(title)
      self.articles.append(title)
    }
    
    // 2. Find all article hrefs.
    parse(doc: doc, xPath: self.articlePath.href) { href in
      let articleURL =
        self.basedOnBaseURL ? self.baseURLString.appendTrimmedRepeatedElementString(href) : href
      print("Find article url \(articleURL)")
      articleURLs.append(articleURL)
      self.articleURLs.append(articleURL)
    }
    
    // 3. Find all article publishDate.
    if let publishDate = self.articlePath.publishDate {
      parse(doc: doc, xPath: publishDate) { date in
        print("Find article url \(date)")
        publishDates.append(date)
        self.publishDates.append(date)
      }
    }
    
    // 4. Find all author names.
    if let avatarName = self.articlePath.authorName {
      parse(doc: doc, xPath: avatarName) { name in
        print("Find name \(name)")
        authorNames.append(name)
        self.authorNames.append(name)
      }
    }
    
    // 5. Find all author avatar.
    if let avatarURL = self.articlePath.authorAvatar {
      parse(doc: doc, xPath: avatarURL) { href in
        let avatarURL =
          self.basedOnBaseURL ? self.baseURLString.appendTrimmedRepeatedElementString(href) : href
        print("Find article url \(avatarURL)")
        authorAvatarURLs.append(avatarURL)
        self.authorAvatarURLs.append(avatarURL)
      }
    }
    
    var currentGeneratedBlogs: [Blog] = []
    if articles.count == articleURLs.count {
      for (index, title) in articles.enumerated() {
        let blog = Blog(title: title,
                        urlString: articleURLs[index],
                        companyName: self.companyName)
        currentGeneratedBlogs.append(blog)
      }
    }
    
    if publishDates.count == articles.count {
      for (index, date) in publishDates.enumerated() {
        let blog = currentGeneratedBlogs[index]
        blog.publishDate = date
      }
    }
    
    if authorNames.count == articles.count {
      for (index, name) in authorNames.enumerated() {
        let blog = currentGeneratedBlogs[index]
        blog.authorName = name
      }
    }
    
    if authorAvatarURLs.count == articles.count {
      for (index, url) in authorAvatarURLs.enumerated() {
        let blog = currentGeneratedBlogs[index]
        blog.authorAvatar = url
      }
    }
    
    self.Blogs.append(contentsOf: currentGeneratedBlogs)

    self.currentDepth += 1
    
    if let nextPageXPath = self.metaData.nextPageXPath {
      parse(doc: doc, xPath: nextPageXPath) { nextPage in
        var toBeParseURLString =
            self.basedOnBaseURL ? self.baseURLString.appendTrimmedRepeatedElementString(nextPage) : nextPage
        toBeParseURLString = toBeParseURLString.appendTrimmedRepeatedElementString("/")
        print("next to be parsed url: \(toBeParseURLString)")
        self.parse(url: toBeParseURLString)
      }
    }
  }
  
  /// Parse a HTML, with xPath.
  private func parse(doc: HTMLDocument, xPath: String, execute:(String) -> ()) {
    for element in doc.xpath(xPath) {
      if let result = element.text {
        execute(result)
      }
    }
  }
}
