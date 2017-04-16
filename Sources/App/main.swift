import Vapor
import VaporPostgreSQL

let drop = Droplet(
  preparations:[Blog.self],
  providers:[VaporPostgreSQL.Provider.self]
)

let testCompany = BlogParser(urlString: "https://engineeringblog.yelp.com/",
                            titleXPath: "//article//h3//a",
                         nextPageXPath: "//div[@class='pagination-block']//div[@class='arrange_unit']//a[@class='u-decoration-none next pagination-links_anchor']/@href",
                        basedOnBaseURL: true)
testCompany.parse()

drop.get("article") { request in
  let articles = try testCompany.articles.makeNode()
  return try drop.view.make("article", Node(node: ["articles" : articles]))
}

drop.get("version") { request in
  if let db = drop.database?.driver as? PostgreSQLDriver {
    let version = try db.raw("SELECT version()")
    return try JSON(node: version)
  } else {
    return "No db connection"
  }
}

drop.get("blogTest") { request in
  var testBlog = Blog(title: "friday", urlString: "http://www.friday.com", companyName: "week")
  try testBlog.save()
  return try JSON(node: Blog.all().makeNode())
}

drop.run()
