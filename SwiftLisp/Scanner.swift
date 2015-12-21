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
  
  init(string: String) {
    self.string = string
  }
  
  func scanString(chomp: String) -> Bool {
    if matchesAtLocation(chomp) {
      location += chomp.characters.count
      return true
    }
    return false
  }
  
  func scanUpToString(matchTo: String) -> String? {
    let startLocation = location
    while !matchesAtLocation(matchTo) && location < string.characters.count {
      location += 1
    }
    if matchesAtLocation(matchTo) {
      return string[startLocation..<location]
    }
    location = startLocation
    return nil
  }
  
  func scanUpToString(matchTo terms: String...) -> String? {
    let startLocation = location
    while terms.map({ !matchesAtLocation($0) }).filter({ $0 }).count > 0 && location < string.characters.count {
      location += 1
    }
    if terms.map({ !matchesAtLocation($0) }).filter({ $0 }).count > 0 {
      return string[startLocation..<location]
    }
    location = startLocation
    return nil
  }
  
  func scanUpToCharacter(matchTo: Character...) -> String? {
    let chars = Set(matchTo)
    let startLocation = location
    while location < string.characters.count && !chars.contains(string[location]) {
      location += 1
    }
    if location < string.characters.count && chars.contains(string[location]) && location > startLocation {
      return string[startLocation..<location]
    }
    location = startLocation
    return nil
  }
  
  func scanUpToCharacterOrEnd(matchTo: Character...) -> String? {
    let chars = Set(matchTo)
    let startLocation = location
    while location < string.characters.count && !chars.contains(string[location]) {
      location += 1
    }
    if location > startLocation {
      return string[startLocation..<location]
    }
    location = startLocation
    return nil
  }
  
  // TODO This should work with all whitespace..
  func scanWhitespace() -> Int {
    let start = location
    while location < string.characters.count && (string[location] == " " || string[location] == "\n") {
      location += 1
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
}