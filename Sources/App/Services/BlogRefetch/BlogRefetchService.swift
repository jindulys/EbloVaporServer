//
//  BlogRefetchService.swift
//  EbloVaporServer
//
//  Created by yansong li on 2017-05-27.
//
//

import Foundation
import Dispatch

/// The service that refetchs blogs.
class BlogRefetchService {
  
  /// The blog crawling service.
  var blogCrawlingService: BlogCrawlingService = BlogCrawlingService()
  
  /// Start service
  func startService() {
    print("--- Start new service \(Date())")
    self.blogCrawlingService.startService(automaticallySaveWhenCrawlingFinished: true)
    DispatchQueue.global().asyncAfter(deadline: .now() + 60, execute: {
      print("--- Will start new service")
      self.startService()
    })
  }
}
