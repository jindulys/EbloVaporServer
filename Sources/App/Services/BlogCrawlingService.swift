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
  
  /// Start service
  func startService() {
    let yelpArticleInfo = ArticleInfoPath(title: "//article//h3//a",
                                          href: "//article//h3//a/@href",
                                          authorName: "//article//div[@class='post-info']//img/@alt",
                                          authorAvatar: "//article//div[@class='post-info']//img/@src",
                                          publishDate: "//article//div[@class='post-info']//li[@class='post-date']")
    let yelpMetaData = BlogMetaInfo(nextPageXPath: "//div[@class='pagination-block']//div[@class='arrange_unit']//a[@class='u-decoration-none next pagination-links_anchor']/@href")
    
    let testCompany = BlogParser(baseURLString: "https://engineeringblog.yelp.com/",
                                 articlePath: yelpArticleInfo,
                                 metaData: yelpMetaData,
                                 basedOnBaseURL: true)
    testCompany.parse()
    
    self.crawledBlog = testCompany.Blogs
  }
}
