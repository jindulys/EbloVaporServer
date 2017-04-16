import Vapor

let drop = Droplet()

let testCompany = BlogParserTest(urlString: "https://engineeringblog.yelp.com/",
                                 titleXPath: "//article//h3//a",
                                 nextPageXPath: "//div[@class='pagination-block']//div[@class='arrange_unit']//a[@class='u-decoration-none next pagination-links_anchor']/@href",
                                 basedOnBaseURL: true)
testCompany.parse()

drop.get("article") { request in
  let articles = try testCompany.articles.makeNode()
  return try drop.view.make("article", Node(node: ["articles" : articles]))
}

drop.run()
