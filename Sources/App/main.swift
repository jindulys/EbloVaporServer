import Dispatch
import Vapor
import VaporPostgreSQL

let drop = Droplet()

try drop.addProvider(VaporPostgreSQL.Provider)
drop.preparations += Blog.self

let blogController = BlogController()
blogController.addRoutes(drop: drop)
drop.resource("blogs", blogController)

let blogCrawlingService = BlogCrawlingService()
blogCrawlingService.startService()

// Use timer to save parsed blog later, since right now database does not work.
let timer = DispatchSource.makeTimerSource()
timer.setEventHandler() {
  blogCrawlingService.crawledBlog.forEach { blog in
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
timer.scheduleOneshot(deadline: .now() + 6)
if #available(OSX 10.12, *) {
  timer.activate()
} else {
  // Fallback on earlier versions
}

drop.run()
