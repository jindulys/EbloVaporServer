import Dispatch
import Vapor
import VaporPostgreSQL

let drop = Droplet()

try drop.addProvider(VaporPostgreSQL.Provider)
drop.preparations += Blog.self

let blogController = BlogController()
blogController.addRoutes(drop: drop)
drop.resource("blogs", blogController)

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

var parsedBlog = testCompany.articles.map {
  return Blog(title: $0, urlString: $0, companyName: "Yelp")
}

// Use timer to save parsed blog later, since right now database does not work.
let timer = DispatchSource.makeTimerSource()
timer.setEventHandler() {
  parsedBlog.forEach { blog in
    print("execute")
    var toSave = blog
    do {
      try toSave.save()
      print("Save blog")
    } catch{
      print("Some Error\(error)")
    }
  }
}

let now = DispatchTime.now()
timer.scheduleOneshot(deadline: .now() + 1)
if #available(OSX 10.12, *) {
  timer.activate()
} else {
  // Fallback on earlier versions
}

drop.run()
