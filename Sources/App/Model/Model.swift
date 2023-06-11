//
//  File.swift
//  
//
//  Created by Maxim Macari on 10/6/23.
//

import Foundation
import Vapor

struct Move: Codable {
  let player: String
  let row: Int
  let col: Int
}

struct Board: Codable {
  var layout: [[String?]]
  var error: String
  var result: String
}

enum EventEnum: String, Codable {
  case move = "move"
}
