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
    layout: [
      [nil, nil, nil],
      [nil, nil, nil],
      [nil, nil, nil]
    ],
    error: "",
    result: ""
  )
  var size: Int { self.board.layout.count }
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
    print("\(#function) - ")
    // Verificar si hay un ganador en filas
    for row in board.layout {
      if let player = row[0], row.allSatisfy({ $0 == player }) {
        print("\(#function) - found winner in rows")
        return true
      }
    }
    // Verificar si hay un ganador en columnas
    for col in 0..<board.layout[0].count {
      let column = board.layout.map({ $0[col] })
      if let player = column[0], column.allSatisfy({ $0 == player }) {
        print("\(#function) - found winner in cols")
        return true
      }
    }
    // Verificar si hay un ganador en diagonales
    if let player = board.layout[0][0],
       player == board.layout[1][1] &&
        player == board.layout[2][2] {
      print("\(#function) - found winner in diagonal")
      return true
    }
    // Verificar si hay un ganador en diagonales
    if let player = board.layout[0][2],
       player == board.layout[1][1] &&
        player == board.layout[2][0] {
      print("\(#function) - found winner in diagonal")
      return true
    }
    // Verificar si el tablero está lleno (empate)
    if isBoardFull() {
      print("\(#function) - board is full")
      return true
    }
    return false
  }
  
  mutating func makeMove(row: Int, col: Int, player: String) -> Bool {
    print("\(#function) - ")
    guard row < self.board.layout.count else {
      print("\(#function) - row is out of bounds")
      return false
    }
    guard col < self.board.layout[0].count else {
      print("\(#function) - col is out of bounds")
      return false
    }
    self.board.layout[row][col] = player
    print("\(#function) move made: [\(row)][\(col)]")
    print("\(#function) - \(self.board.layout)")
    return true
  }
  func getAvailableMoves() -> [Move] {
    var availableMoves: [Move] = []
    for row in 0..<self.size {
      for col in 0..<self.size {
        if board.layout[row][col] == nil {
          availableMoves.append(Move(player: "", row: row, col: col))
        }
      }
    }
    
    return availableMoves
  }
  mutating func undoMove(row: Int, col: Int) {
    print("\(#function) - ")
    self.board.layout[row][col] = nil
  }
  func getWinner() -> String? {
    print("\(#function) - ")
    let winningCombinations: [[(row: Int, col: Int)]] = [
      // Rows
      [(0, 0), (0, 1), (0, 2)],
      [(1, 0), (1, 1), (1, 2)],
      [(2, 0), (2, 1), (2, 2)],
      // Columns
      [(0, 0), (1, 0), (2, 0)],
      [(0, 1), (1, 1), (2, 1)],
      [(0, 2), (1, 2), (2, 2)],
      // Diagonals
      [(0, 0), (1, 1), (2, 2)],
      [(0, 2), (1, 1), (2, 0)]
    ]
    for combination in winningCombinations {
      let cells = combination.map { self.board.layout[$0.row][$0.col] }
      let uniqueCells = Set(cells)
      if uniqueCells.count == 1 && !uniqueCells.contains(nil) {
        return uniqueCells.first!
      }
    }
    return nil
  }
}
