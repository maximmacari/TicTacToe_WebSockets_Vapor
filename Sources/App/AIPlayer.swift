//
//  AIPlayer.swift
//  
//
//  Created by Maxim Macari on 12/6/23.
//

import Foundation
import Vapor

class AIPlayer {
  private let name = "AI"
  func getBestMove(game: Game) -> Move? {
    print("\(#function) - ")
    var mutableGame = game
    let availableMoves = mutableGame.getAvailableMoves()
    for move in availableMoves {
      print("Available move: \(move)")
      let row = move.row
      let col = move.col
      guard mutableGame.makeMove(row: row, col: col, player: name) else {
        continue
      }
      if mutableGame.isGameOver() && mutableGame.getWinner() == name {
        return move
      }
      mutableGame.undoMove(row: row, col: col)
    }
    if let randomMove = availableMoves.randomElement() {
      return randomMove
    }
    return nil
  }
}
