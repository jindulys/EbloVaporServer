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
import Vapor

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
  
  /// Whether or not fetch all blogs.
  /// If we have fetched this blog then next time what we should do is only check
  /// the first page to avoid repeated fetching all blogs.
  public let fetchAllBlogs: Bool
  
  /// Array contains all the article titles founded.
  public private(set) var articles: [String] = []
  
  /// Whether or not current parser finishes its parsing job.
  public private(set) var finished: Bool
  
  /// Array for articleURLs.
  public private(set) var articleURLs: [String] = []
  
  /// Array for publish dates.
  public private(set) var publishDates: [String] = []
  
  /// Array for author names.
  public private(set) var authorNames: [String] = []
  
  /// Array for author avatar urls.
  public private(set) var authorAvatarURLs: [String] = []
  
  /// Array for parse blog.
  public private(set) var blogs: [Blog] = []
  
  /// A set of parsed url.
  private var parsedURLString: Set<String> = []
  
  /// The company of this blog parser.
  /// NOTE: This is used to update company's information.
  public var company: Company
  
  /// The maximum depth for blog pagination.
  private var maxDepth: Int
  
  /// Current depth has processed.
  private var currentDepth: Int = 0
  
  init(baseURLString: String,
       articlePath: ArticleInfoPath,
       metaData: BlogMetaInfo,
       companyName: String,
       basedOnBaseURL: Bool,
       company: Company,
       fetchAllBlogs: Bool) {
    self.baseURLString = baseURLString
    self.articlePath = articlePath
    self.metaData = metaData
    self.companyName = companyName
    self.basedOnBaseURL = basedOnBaseURL
    self.finished = false
    self.company = company
    self.fetchAllBlogs = fetchAllBlogs
    self.maxDepth = self.fetchAllBlogs ? 20 : 1
  }
  
  /// Parse this company's blog.
  public func parse() {
    self.parse(completion: nil)
  }
  
  public func parse(completion: ((Bool) -> ())?) {
    self.finished = false
    parse(urlString: self.baseURLString)
    self.finished = true
    print("Parse Finished, total found \(self.articles.count) aritcles")
    print("Parse Finished, total found \(self.articleURLs.count) article urls")
    print("Parse Finished, total found \(self.publishDates.count) dates")
    if let firstBlog = self.blogs.first,
      firstBlog.title != self.company.firstBlogTitle {
      // If first blog title has changed, update company's first blog title.
      self.company.firstBlogTitle = firstBlog.title
      do {
        try self.company.save()
      } catch {
        print("Can not save company's first blog title update")
      }
    }
    self.parsedURLString.removeAll()
    // NOTE: Here we revert the order of parsed blog, so the first found which should be the latest
    // will actually be the last of the array. This is helpful for orderring blogs in a time-reasonable
    // way.
    self.blogs = self.blogs.reversed()
    if let completion = completion {
      completion(true)
    }
  }
  
  // MARK: Priave
  /// Parse a URL.
  private func parse(urlString: String) {
    guard self.currentDepth < maxDepth else {
      print("Blog Parser has reached the max depth")
      return
    }
    
    guard !self.parsedURLString.contains(urlString) else {
      print("All parsed")
      return
    }
    
    guard let url = URL(string: urlString) else {
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
    var publishDateIntervals: [Double] = []
    var authorNames: [String] = []
    var authorAvatarURLs: [String] = []
    
    // 1. Find and print all title in current page.
    parse(doc: doc, xPath: self.articlePath.title) { title in
      //print("Find article \(title)")
      articles.append(title)
      self.articles.append(title)
    }
    
    // 2. Find all article hrefs.
    parse(doc: doc, xPath: self.articlePath.href) { href in
      let articleURL =
        self.basedOnBaseURL ? self.baseURLString.appendTrimmedRepeatedElementString(href) : href
      //print("Find article url \(articleURL)")
      articleURLs.append(articleURL)
      self.articleURLs.append(articleURL)
    }
    
    // 3. Find all article publishDate.
    if let publishDate = self.articlePath.publishDate {
      parse(doc: doc, xPath: publishDate) { date in
        let trimmedString = date.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let month = StringParsedDateComponents.month(from: trimmedString)
        let day = StringParsedDateComponents.day(from: trimmedString)
        let year = StringParsedDateComponents.year(from: trimmedString)
        if let parsedDate = StringParsedDateComponents.dateFrom(year: year, month: month, day: day) {
          publishDateIntervals.append(parsedDate.timeIntervalSince1970 as Double)
        }
        publishDates.append(trimmedString)
        self.publishDates.append(date)
      }
    }
    
    // 4. Find all author names.
    if let avatarName = self.articlePath.authorName {
      parse(doc: doc, xPath: avatarName) { name in
        //print("Find author name \(name)")
        authorNames.append(name)
        self.authorNames.append(name)
      }
    }
    
    // 5. Find all author avatar.
    if let avatarURL = self.articlePath.authorAvatar {
      parse(doc: doc, xPath: avatarURL) { href in
        let avatarURL =
          self.basedOnBaseURL ? self.baseURLString.appendTrimmedRepeatedElementString(href) : href
        //print("Find author avatar url \(avatarURL)")
        authorAvatarURLs.append(avatarURL)
        self.authorAvatarURLs.append(avatarURL)
      }
    }
    
    var currentGeneratedBlogs: [Blog] = []
    if articles.count == articleURLs.count {
      for (index, title) in articles.enumerated() {
        let blog = Blog(title: title,
                        urlString: articleURLs[index],
                        companyName: self.companyName,
                        companyId: self.company.id)
        currentGeneratedBlogs.append(blog)
      }
    }
    
    if publishDates.count == articles.count {
      for (index, date) in publishDates.enumerated() {
        let blog = currentGeneratedBlogs[index]
        blog.publishDate = date
      }
    }
    
    if publishDateIntervals.count == articles.count {
      for (index, timeInterval) in publishDateIntervals.enumerated() {
        let blog = currentGeneratedBlogs[index]
        blog.publishDateInterval = timeInterval
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
    
    self.blogs.append(contentsOf: currentGeneratedBlogs)

    self.currentDepth += 1
    self.parsedURLString.insert(urlString)
    
    if let nextPageXPath = self.metaData.nextPageXPath {
      parse(doc: doc, xPath: nextPageXPath) { nextPage in
        var toBeParseURLString =
            self.basedOnBaseURL ? self.baseURLString.appendTrimmedRepeatedElementString(nextPage) : nextPage
        toBeParseURLString = toBeParseURLString.appendTrimmedRepeatedElementString("/")
        if let needRemoveExtraBlog = self.metaData.needRemoveExtraBlog,
          needRemoveExtraBlog == true {
          print("**** Notice remove extra blog")
          toBeParseURLString = toBeParseURLString.replacingOccurrences(of: "blog/blog", with: "blog")
        }
        if let needRemoveEndSlash = self.metaData.needRemoveEndSlash,
          needRemoveEndSlash == true,
          toBeParseURLString.hasSuffix("/") {
          print("**** Notice remove extra blog")
          toBeParseURLString.remove(at: toBeParseURLString.index(before: toBeParseURLString.endIndex))
        }
        print("next to be parsed url: \(toBeParseURLString)")
        self.parse(urlString: toBeParseURLString)
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

extension BlogParser: Unique {
  public func identifier() -> String {
    return baseURLString + companyName
  }
}
