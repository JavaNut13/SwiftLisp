//
//  main.swift
//  SwiftLisp
//
//  Created by Will Richardson on 21/12/15.
//  Copyright © 2015 JavaNut13. All rights reserved.
//

import Foundation

protocol Atom: CustomStringConvertible, ErrorLocatable {
  func expand(space: Space) -> Atom
  var show: String { get }
}

struct Identifier: Atom {
  let value: String
  let location: ErrorLocation?
  
  func expand(space: Space) -> Atom {
    // FIXME This is glitchy
    if let v = space[value] {
      return v
    } else {
      return Nil()
    }
  }
  
  var description: String {
    return value
  }
  var show: String {
    return description
  }
}

struct Literal: Atom {
  let value: Atom
  let location: ErrorLocation?
  
  init(_ value: Atom) {
    self.value = value
    self.location = value.location
  }
  
  func expand(space: Space) -> Atom {
    return self
  }
  
  var description: String {
    return "'" + value.description
  }
  var show: String {
    return "'" + value.show
  }
}

struct Str: Atom {
  let value: String
  let location: ErrorLocation?
  
  init(value: String, location: ErrorLocation?) {
    self.value = value
    self.location = location
  }
  
  func expand(namespace: Space) -> Atom {
    return self
  }
  
  var description: String {
    return "\"" + value + "\""
  }
  var show: String {
    return value
  }
}

struct Num: Atom {
  let value: Int
  let location: ErrorLocation?
  
  init(value: Int) {
    self.value = value
    self.location = nil
  }
  
  init(value: Int, location: ErrorLocation?) {
    self.value = value
    self.location = location
  }
  
  func expand(space: Space) -> Atom {
    return self
  }
  
  var description: String {
    return String(value)
  }
  var show: String {
    return description
  }
}

struct Dec: Atom {
  let value: Float
  let location: ErrorLocation?
  
  init(value: Float) {
    self.value = value
    self.location = nil
  }
  
  init(value: Float, location: ErrorLocation?) {
    self.value = value
    self.location = location
  }
  
  func expand(space: Space) -> Atom {
    return self
  }
  
  var description: String {
    return String(value)
  }
  var show: String {
    return description
  }
}

struct Nil: Atom {
  let location: ErrorLocation?
  
  init() {
    location = nil
  }
  
  init(location: ErrorLocation?) {
    self.location = location
  }
  
  func expand(space: Space) -> Atom {
    return self
  }
  
  var description: String {
    return "nil"
  }
  var show: String {
    return description
  }
}

struct List: Atom {
  let children: [Atom]
  let location: ErrorLocation?
  
  init(children: [Atom], location: ErrorLocation) {
    self.children = children
    self.location = location
  }
  
  init(children: [Atom]) {
    self.children = children
    self.location = nil
  }
  
  var description: String {
    return "(" + children.map({ $0.description }).joinWithSeparator(" ") + ")"
  }
  var show: String {
    return description
  }
}



struct Program: CustomStringConvertible {
  let statements: [Atom]
  
  init(_ input: String) throws {
    var scanner = Scanner(string: input)
    var atoms = [Atom]()
    while let atom = try Program.parseAtom(&scanner) {
      atoms.append(atom)
    }
    statements = atoms
  }
  
  var description: String {
    return statements.map({ $0.description }).joinWithSeparator("\n")
  }
  
  static func parseAtom(inout scanner: Scanner) throws -> Atom? {
    scanner.scanWhitespace()
    // Scan an array
    if scanner.pointingAt("(") {
      return try parseList(&scanner)
    } else if scanner.pointingAt("[") {
      if let list = try parseList(&scanner) {
        return Literal(list)
      } else {
        throw SyntaxError.ExpectedAtom(scanner.errorLocation())
      }
    } else if scanner.pointingAt("\"") { // scan a string
      return try parseString(&scanner)
    } else if scanner.scanString("'") { // scan a 'quoted value
      if let atom = try parseAtom(&scanner) {
        return Literal(atom)
      } else {
        throw SyntaxError.ExpectedAtom(scanner.errorLocation())
      }
    } else if let iden = scanner.scanUpToCharacterOrEnd([" ", ")", "(", "[", "]"]) {
      if let num = Int(iden) {
        return Num(value: num, location: scanner.errorLocation())
      } else if let num = Float(iden) {
        return Dec(value: num, location: scanner.errorLocation())
      } else {
        if iden == "nil" {
          return Nil()
        } else {
          return Identifier(value: iden, location: scanner.errorLocation())
        }
      }
    } else {
      return nil
    }
  }
  
  static func parseList(inout scanner: Scanner) throws -> List? {
    scanner.scanWhitespace()
    let endChar: String
    if scanner.scanString("(") {
      endChar = ")"
    } else if scanner.scanString("[") {
      endChar = "]"
    } else {
      return nil
    }
    var atoms = [Atom]()
    while let atom = try parseAtom(&scanner) {
      atoms.append(atom)
    }
    if scanner.scanString(endChar) {
      return List(children: atoms, location: scanner.errorLocation())
    } else {
      throw SyntaxError.ExpectedParen(scanner.errorLocation())
    }
  }
  
  static func parseString(inout scanner: Scanner) throws -> Str? {
    scanner.scanWhitespace()
    if scanner.scanString("\"") {
      if let iden = scanner.scanUpToCharacter(["\""]) {
        scanner.scanString("\"")
        return Str(value: iden, location: scanner.errorLocation())
      } else {
        throw SyntaxError.ExpectedQuote(scanner.errorLocation())
      }
    } else {
      return nil
    }
  }
}



