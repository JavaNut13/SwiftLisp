//
//  Scanner.swift
//  Language
//
//  Created by Will Richardson on 4/12/15.
//  Copyright © 2015 JavaNut13. All rights reserved.
//

import Foundation

extension String {
  subscript(indexes: Range<Int>) -> String {
    let start = self.startIndex.advancedBy(indexes.startIndex)
    let end = self.startIndex.advancedBy(indexes.endIndex)
    return self.substringWithRange(start..<end)
  }
  subscript(range: NSRange) -> String {
    return self[range.location..<range.length + range.location]
  }
  subscript(index: Int) -> Character {
    return self.characters[startIndex.advancedBy(index)]
  }
}

class Scanner: CustomStringConvertible {
  let string: String
  var location: Int = 0
  
  var row: Int = 0
  var col: Int = 0
  
  private var lastLocation: Int = 0
  
  private var lastRow: Int = 0
  private var lastCol: Int = 0
  
  init(string: String) {
    self.string = string
  }
  
  func scanString(chomp: String) -> Bool {
    if matchesAtLocation(chomp) {
      var n = 0
      while n < chomp.characters.count {
        advance()
        n += 1
      }
      return true
    }
    return false
  }
  
  func scanUpToString(matchTo: String) -> String? {
    let startLocation = location
    remember()
    while !matchesAtLocation(matchTo) && location < string.characters.count {
      advance()
    }
    if matchesAtLocation(matchTo) {
      return string[startLocation..<location]
    }
    reset()
    return nil
  }
  
  func scanUpToString(matchTo terms: String...) -> String? {
    let startLocation = location
    remember()
    while terms.map({ !matchesAtLocation($0) }).filter({ $0 }).count > 0 && location < string.characters.count {
      advance()
    }
    if terms.map({ !matchesAtLocation($0) }).filter({ $0 }).count > 0 {
      return string[startLocation..<location]
    }
    reset()
    return nil
  }
  
  func scanUpToCharacter(matchTo: [Character]) -> String? {
    let chars = Set(matchTo)
    let startLocation = location
    remember()
    while location < string.characters.count && !chars.contains(string[location]) {
      advance()
    }
    if location < string.characters.count && chars.contains(string[location]) && location > startLocation {
      return string[startLocation..<location]
    }
    reset()
    return nil
  }
  
  func scanUpToCharacterOrEnd(matchTo: [Character]) -> String? {
    let chars = Set(matchTo)
    let startLocation = location
    remember()
    while location < string.characters.count && !chars.contains(string[location]) {
      advance()
    }
    if location > startLocation {
      return string[startLocation..<location]
    }
    reset()
    return nil
  }
  
  // TODO This should work with all whitespace..
  func scanWhitespace() -> Int {
    let start = location
    while location < string.characters.count && (string[location] == " " || string[location] == "\n") {
      advance()
    }
    return location - start;
  }
  
  func pointingAt(char: Character) -> Bool {
    return location < string.characters.count && string[location] == char
  }
  
  func matchesAtLocation(with: String) -> Bool {
    let stringLength = string.characters.count
    let withLength = with.characters.count
    return location < stringLength && location + withLength <= stringLength && string[location..<(withLength + location)] == with
  }
  
  var description: String {
    return string[0..<location] + "|" + string[location..<string.characters.count]
  }
  
  func errorLocation() -> ErrorLocation {
    return ErrorLocation(row: row, column: col)
  }
  
  /// Save the current location of the pointer
  private func remember() {
    lastLocation = location
    lastRow = row
    lastCol = col
  }
  
  /// Move the pointer back to where it was saved at
  private func reset() {
    location = lastLocation
    row = lastRow
    col = lastCol
  }
  
  private func advance() {
    location += 1
    if location < string.characters.count && string[location] == "\n" {
      row += 1
      col = -1
    } else {
      col += 1
    }
  }
}