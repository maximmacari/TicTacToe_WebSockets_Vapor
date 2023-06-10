//
//  File.swift
//  
//
//  Created by Maxim Macari on 10/6/23.
//

import Foundation
import Vapor

final class WebSocketController {
  var connectedSockets: [WebSocket] = []
  var game: Game?
  private let jsonEncoder = JSONEncoder()
  
  init() {
    jsonEncoder.outputFormatting = .prettyPrinted
  }
  
  func connect(_ req: Request, _ ws: WebSocket) throws {
    req.logger.info("\(#function) - ")
    let game = Game()
    self.game = game
    let initialState = game.board
    ws.send("Biendvenido \(req.peerAddress?.hostname ?? "anónimo")")
    connectedSockets.append(ws)
    ws.onText { ws, text in
      req.logger.info("Received text message from WebSocket: \(text)")
      ws.send("Server received your message: \(text)")
      do {
        try self.receive(req, ws, text)
      } catch {
        req.logger.info("Colud not decode: \(text)")
      }
    }
    ws.onClose.whenComplete { _ in
      if let index = self.connectedSockets.firstIndex(where: { $0 === ws }) {
        self.connectedSockets.remove(at: index)
      }
    }
  }
  func disconnect(_ req: Request, _ ws: WebSocket) {
    req.logger.info("\(#function) - ")
  }
  func receive(_ req: Request, _ ws: WebSocket, _ text: String) throws {
    req.logger.info("\(#function) - text: \(text)")
    let decoder = JSONDecoder()
    let move = try decoder.decode(Move.self, from: Data(text.utf8))
    guard game != nil else {
      req.logger.info("game is not initialized")
      return
    }
    let player = move.player
    let row = move.row
    let col = move.col
    guard game!.makeMove(row: row, col: col, player: player) else {
      game!.board.error = "Invalid move"
      ws.send("Error, cant move.")
      return
    }
    if game!.isGameOver() {
      game!.board.result = "GAME OVER"
    } else if game!.isBoardFull() {
      game!.board.result = "DRAW"
    }
    let responseData = try jsonEncoder.encode(game!.board)
    ws.send(String(data: responseData, encoding: .utf8)!)
  }
}

struct Move: Content {
  let player: String
  let row: Int
  let col: Int
}

struct Board: Codable {
  var error: String
  var layout: [[String?]]
  var result: String
}
