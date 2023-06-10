import Vapor

// configures your application
public func configure(_ app: Application) async throws {
  // uncomment to serve files from /Public folder
  // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
  let webSocketController = WebSocketController()
  app.webSocket("game", onUpgrade: { req, ws in
    do {
      try webSocketController.connect(req, ws)
    } catch {
      // Handle the error appropriately
      print("WebSocket connection failed: \(error)")
      ws.close(code: .goingAway)
    }
  })
  
  // register routes
  try routes(app)
}
