import Vapor
import Foundation

public func configure(_ app: Application) async throws {
  let webSocketController = WebSocketController()
  app.webSocket("game", onUpgrade: { req, ws in
    do {
      try webSocketController.connect(req, ws)
    } catch {
      print("WebSocket connection failed: \(error)")
      ws.close(code: .goingAway)
    }
  })
  app.webSocket("subscribe", ":event") { res, ws in
    print("subscribed to :event")
  }
  try routes(app)
}
