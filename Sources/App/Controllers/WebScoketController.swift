//
//  File.swift
//  
//
//  Created by Maxim Macari on 10/6/23.
//

import Foundation
import Vapor

final class WebSocketController {
  private let jsonDecoder = JSONDecoder()
  private let jsonEncoder = JSONEncoder()
  var connectedSockets: [WebSocket] = []
  var game: Game!
  init() {
    jsonEncoder.outputFormatting = .prettyPrinted
  }
  func connect(_ req: Request, _ ws: WebSocket) throws {
    req.logger.info("\(#function) - ")
    let game = Game()
    self.game = game
    let initialState = game.board
    ws.send("Bienvenido \(req.peerAddress?.port)")
    ws.send("Bienvenido \(req.peerAddress?.hostname ?? "anónimo")")
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
    guard game != nil else {
      req.logger.info("game is not initialized")
      return
    }
    
    
    let jsonData = text.data(using: .utf8)!
    let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any]
    
    if let event = json["event"] as? String,
       let dataDic = json["data"] as? [String: Any] {
      let data = try JSONSerialization.data(withJSONObject: dataDic)
      switch EventEnum(rawValue: event) {
      case .move:
        let move = try jsonDecoder.decode(Move.self, from: data)
        try handleMove(req, ws, move)
      default:
        break
      }
    }
  }
  private func handleMove(_ req: Request, _ ws: WebSocket, _ move: Move) throws {
    guard game.makeMove(
      row: move.row,
      col: move.col,
      player: "\(req.remoteAddress!.port)") else {
      game.board.error = "Invalid move"
      ws.send("Error, cant move")
      return
    }
    if game.isGameOver() {
      game.board.result = "GAME OVER"
    } else if game.isBoardFull() {
      game.board.result = "DRAW"
    }
    let responseData = try jsonEncoder.encode(game.board)
    ws.send(String(data: responseData, encoding: .utf8)!)
  }
}
