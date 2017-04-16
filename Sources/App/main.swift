import Vapor

let drop = Droplet()

drop.get { request in
  return try JSON(node: [
    "message" : "Hello, Vapor!"
    ])
}

drop.run()
