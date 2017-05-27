import Dispatch
import Vapor
import VaporPostgreSQL

let drop = Droplet()

try drop.addProvider(VaporPostgreSQL.Provider)
drop.preparations += Blog.self

let blogController = BlogController()
blogController.addRoutes(drop: drop)
drop.resource("blogs", blogController)

// The home page request.
drop.get { request in
  return "Hello"
}

let blogCrawlingService = BlogCrawlingService()
blogCrawlingService.startService()

// Use timer to save parsed blog later, since right now database does not work.
let timer = DispatchSource.makeTimerSource()
timer.setEventHandler() {
  // TODO(simonli): Create a `service` protocol to make this more like a work-flow.
  do {
    let existingBlogs = try Blog.all()
    let existingIdentifiers = existingBlogs.map { blog in
      return blog.string()
    }
    blogCrawlingService.crawledBlog.forEach { blog in
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
}
timer.scheduleOneshot(deadline: .now() + 6)
if #available(OSX 10.12, *) {
  timer.activate()
} else {
  // Fallback on earlier versions
}

drop.run()
