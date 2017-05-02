//
//  BlogCrawlingService.swift
//  EbloVaporServer
//
//  Created by yansong li on 2017-04-28.
//
//

import Foundation

/// The service to start a blog crawling.
class BlogCrawlingService {

  /// The crawledblogs.
  var crawledBlog: [Blog] = []
  
  private var blogParsers: [BlogParser] = []
  
  /// Start service
  func startService() {
    var url = URL(string: "https://api.myjson.com/bins/1g604t")
    #if os(OSX)
    if EnviromentManager.local {
      let resourceName = EnviromentManager.newCompany ? "newCompany" : "company"
      let urlPath = Bundle.main.path(forResource: resourceName, ofType: "json")
      url = NSURL.fileURL(withPath: urlPath!)
    }
    #endif
    guard let data = try? Data(contentsOf: url!) else {
      print("\(self) can not load data from URL \(url!)")
      return
    }
    do {
      let json =
        try JSONSerialization.jsonObject(with: data,
                                         options: [.mutableContainers, .allowFragments])
      guard let jsonData = json as? [String: Any],
        let companies = jsonData["company"] as? [[String: Any]] else {
          return
      }
      
      for companyInfo in companies {
        // Create blog parsers.
        if let titlePath = companyInfo["title"] as? String,
          let href = companyInfo["href"] as? String,
          let baseURL = companyInfo["baseURL"] as? String,
          let basedOnBase = companyInfo["basedOnBase"] as? Bool,
          let companyName = companyInfo["name"] as? String {
          let articleInfo = ArticleInfoPath(title: titlePath,
                                            href: href,
                                            authorName: companyInfo["author"] as? String,
                                            authorAvatar: companyInfo["authorAvatar"] as? String,
                                            publishDate: companyInfo["date"] as? String)
          let metaInfo = BlogMetaInfo(nextPageXPath: companyInfo["nextPage"] as? String)
          let companyParser = BlogParser(baseURLString: baseURL,
                                         articlePath: articleInfo,
                                         metaData: metaInfo,
                                         companyName: companyName,
                                         basedOnBaseURL: basedOnBase)
          self.blogParsers.append(companyParser)
        }
      }
      
      self.blogParsers.forEach { parser in
        parser.parse { finished in
          self.crawledBlog.append(contentsOf: parser.Blogs)
        }
      }
    } catch {
      print(error)
    }
  }
}
