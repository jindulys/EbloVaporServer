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
blogCrawlingService.startService(automaticallySaveWhenCrawlingFinished: false)

// Use timer to save parsed blog later, since right now database does not work.
let timer = DispatchSource.makeTimerSource()
timer.setEventHandler() {
  blogCrawlingService.saveCrawledBlog()
  print("---- ----- Notice start cron job")
  let blogRefetchService = BlogRefetchService()
  blogRefetchService.startService()
}

timer.scheduleOneshot(deadline: .now() + 16)
if #available(OSX 10.12, *) {
  timer.activate()
} else {
  // Fallback on earlier versions
}

drop.run()
