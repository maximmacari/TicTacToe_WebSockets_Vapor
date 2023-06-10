//
//  File.swift
//  
//
//  Created by Maxim Macari on 10/6/23.
//

import Foundation
import Vapor

struct Game {
  var board = Board(
    error: "",
    layout: [
      [nil, nil, nil],
      [nil, nil, nil],
      [nil, nil, nil]
    ],
    result: ""
  )
  func isBoardFull() -> Bool {
    for row in self.board.layout {
      for cell in row {
        if cell == nil {
          return false
        }
      }
    }
    return true
  }
  func isGameOver() -> Bool {
    // Verificar si hay un ganador en filas
    for row in board.layout {
      if let player = row[0], row.allSatisfy({ $0 == player }) {
        return true
      }
    }
    // Verificar si hay un ganador en columnas
    for col in 0..<board.layout[0].count {
      let column = board.layout.map({ $0[col] })
      if let player = column[0], column.allSatisfy({ $0 == player }) {
        return true
      }
    }
    // Verificar si hay un ganador en diagonales
    if let player = board.layout[0][0],
       player == board.layout[1][1] &&
        player == board.layout[2][2] {
      return true
    }
    // Verificar si hay un ganador en diagonales
    if let player = board.layout[0][2],
       player == board.layout[1][1] &&
        player == board.layout[2][0] {
      return true
    }
    // Verificar si el tablero está lleno (empate)
    if isBoardFull() {
      return true
    }
    return false
  }
  
  mutating func makeMove(row: Int, col: Int, player: String) -> Bool {
    guard row < self.board.layout.count else {
      print("row is out of bounds")
      return false
    }
    guard col < self.board.layout[0].count else {
      print("col is out of bounds")
      return false
    }
    self.board.layout[row][col] = player
    print("\(#function) move made: [\(row)][\(col)]- ")
    print("\(#function) - \(self.board.layout)")
    return true
  }
}
