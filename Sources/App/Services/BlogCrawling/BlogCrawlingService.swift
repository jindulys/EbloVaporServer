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
  
  /// The blogParsers.
  private var blogParsers: [BlogParser] = []
  
  /// Whether or not automatically save crawled blog when crawling finishes.
  private var automaticallySaveWhenCrawlingFinished = false
  
  /// Whether or not blog crawling has finished.
  var crawlingFinished: Bool = false {
    didSet {
      if (crawlingFinished && !oldValue) && automaticallySaveWhenCrawlingFinished {
        // Add in a test yelp blog
//        let testBlog = Blog(title: "Hoooooool lllll",
//                            urlString: "http://yelp.com/test",
//                            companyName: "Yelp")
//        testBlog.publishDate = "May, 27, 2017"
//        testBlog.publishDateInterval = Date().timeIntervalSince1970
//        self.crawledBlog.append(testBlog)
        self.saveCrawledBlog()
      }
    }
  }
  
  /// Start service
  func startService(automaticallySaveWhenCrawlingFinished: Bool) {
    crawlingFinished = false
    var url: URL? = nil
    #if os(OSX)
    if EnviromentManager.local {
      let resourceName = EnviromentManager.newCompany ? "newCompany" : "company"
      let urlPath = Bundle.main.path(forResource: resourceName, ofType: "json")
      url = NSURL.fileURL(withPath: urlPath!)
    }
    #endif
    if url == nil {
      let companySource = try! CompanySource.all()
      guard companySource.count > 0,
        let companySourceURLString = companySource.first?.companyDataURLString else {
          return
      }
      url = URL(string: companySourceURLString)
    }
    
    self.automaticallySaveWhenCrawlingFinished = automaticallySaveWhenCrawlingFinished

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
      
      /// The current existed companies.
      var existingCompaniesDict: [String : Company] = [:]
      do {
        let existingCompanies = try Company.all()
        existingCompanies.forEach { company in
          existingCompaniesDict[company.string()] = company
        }
      } catch {
        print("Can not load Company from data base.")
      }
      
      for companyInfo in companies {
        // Create blog parsers.
        if let titlePath = companyInfo["title"] as? String,
          let href = companyInfo["href"] as? String,
          let baseURL = companyInfo["baseURL"] as? String,
          let basedOnBase = companyInfo["basedOnBase"] as? Bool,
          let companyName = companyInfo["name"] as? String {
          
          // Create company instance.
          var company = Company(companyName: companyName, companyUrlString: baseURL)
          
          var newCompany = false
          // Check whether this company exist or not, set company to correct value.
          if let exist = existingCompaniesDict[company.string()],
            company.companyUrlString == exist.companyUrlString {
            company = exist
          } else {
            newCompany = true
            // Use the new information of a company.
            var toSave = company
            if let exist = existingCompaniesDict[company.string()] {
              // If we already have existing one, we use the existing one's id.
              toSave.id = exist.id
              do {
                // We need to delete existing one from data base, because there is no update.
                try exist.delete()
              } catch {
                print("Can not delete existing company")
              }
            }
            do {
              try toSave.save()
              existingCompaniesDict[toSave.string()] = toSave
              company = toSave
            } catch {
              print("Some Error \(error)")
            }
          }
          
          let articleInfo = ArticleInfoPath(title: titlePath,
                                            href: href,
                                            authorName: companyInfo["author"] as? String,
                                            authorAvatar: companyInfo["authorAvatar"] as? String,
                                            publishDate: companyInfo["date"] as? String)
          
          let metaInfo = BlogMetaInfo(nextPageXPath: companyInfo["nextPage"] as? String,
                                      needRemoveExtraBlog: companyInfo["needRemoveRepeatBlog"] as? Bool,
                                      needRemoveEndSlash: companyInfo["needRemoveEndSlash"] as? Bool)

          if let validCompanyID = company.id {
            print("--- create valid parser for company: \(company.companyName) id: \(validCompanyID).")
            let companyParser = BlogParser(baseURLString: baseURL,
                                           articlePath: articleInfo,
                                           metaData: metaInfo,
                                           companyName: companyName,
                                           basedOnBaseURL: basedOnBase,
                                           company: company,
                                           fetchAllBlogs: newCompany)
            self.blogParsers.append(companyParser)
          }
        }
      }

      self.blogParsers.forEach { parser in
        parser.parse { finished in
          self.crawledBlog.append(contentsOf: parser.blogs)
          self.checkCrawlingStatus()
        }
      }
    } catch {
      print(error)
    }
  }
  
  /// Save crawled blogs.
  func saveCrawledBlog() {
    if self.crawlingFinished {
      do {
        let existingBlogs = try Blog.all()
        let existingIdentifiers = existingBlogs.map { blog in
          return blog.string()
        }
        self.crawledBlog.forEach { blog in
          if existingIdentifiers.contains(blog.string()) {
            return
          }
          print("This blog does not exist in our data base\(blog.string())")
          var toSave = blog
          do {
            try toSave.save()
          } catch {
            print("Some Error \(error)")
          }
        }
      } catch {
        print("Can not load Blogs from data base.")
      }
    } else {
      print("BlogCrawlingService not finish yet.")
    }
    self.automaticallySaveWhenCrawlingFinished = false
  }
  
  private func checkCrawlingStatus() {
    self.crawlingFinished =
      self.blogParsers.filter { $0.finished == false }.count == 0
  }
}
