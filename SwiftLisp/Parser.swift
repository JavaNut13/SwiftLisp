//
//  main.swift
//  SwiftLisp
//
//  Created by Will Richardson on 21/12/15.
//  Copyright © 2015 JavaNut13. All rights reserved.
//

import Foundation

protocol Atom: CustomStringConvertible, ErrorLocatable {
  var quoted: Bool { get set }
  func run(namespace: Namespace) -> Atom
  var show: String { get }
}

struct Identifier: Atom {
  let value: String
  var quoted: Bool
  let location: ErrorLocation?
  
  func run(namespace: Namespace) -> Atom {
    // FIXME This is glitchy
    if var v = namespace[value] {
      v.quoted = quoted
      return v
    } else {
      return Nil()
    }
  }
  
  var description: String {
    return (quoted ? "'" : "") + value
  }
  var show: String {
    return description
  }
}

struct Str: Atom {
  let value: String
  var quoted: Bool
  let location: ErrorLocation?
  
  init(value: String, location: ErrorLocation?) {
    self.value = value
    quoted = false
    self.location = location
  }
  
  func run(namespace: Namespace) -> Atom {
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
  var quoted: Bool
  let location: ErrorLocation?
  
  init(value: Int) {
    self.value = value
    quoted = false
    self.location = nil
  }
  
  init(value: Int, location: ErrorLocation?) {
    self.value = value
    quoted = false
    self.location = location
  }
  
  func run(namespace: Namespace) -> Atom {
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
  var quoted = false
  
  init() {
    location = nil
  }
  
  init(location: ErrorLocation?) {
    self.location = location
  }
  
  func run(namespace: Namespace) -> Atom {
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
  var quoted: Bool
  let location: ErrorLocation?
  
  init(children: [Atom], quoted: Bool, location: ErrorLocation) {
    self.children = children
    self.quoted = quoted
    self.location = location
  }
  
  init(children: [Atom], quoted: Bool) {
    self.children = children
    self.quoted = quoted
    self.location = nil
  }
  
  var description: String {
    return (quoted ? "'(" : "(") + children.map({ $0.description }).joinWithSeparator(" ") + ")"
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
    if scanner.pointingAt("(") || scanner.pointingAt("[") {
      return try parseList(&scanner)
    } else if scanner.pointingAt("\"") { // scan a string
      return try parseString(&scanner)
    } else if scanner.scanString("'") { // scan a 'quoted value
      let atom = try parseAtom(&scanner)
      if var eval = atom {
        eval.quoted = true
        return eval
      } else {
        return atom
      }
    } else { // scan an identifier or number value
      // These chars should terminate the atom
      if let iden = scanner.scanUpToCharacterOrEnd([" ", ")", "(", "[", "]"]) {
        if let num = Int(iden) {
          return Num(value: num, location: scanner.errorLocation())
        } else {
          if iden == "nil" {
            return Nil()
          } else {
            return Identifier(value: iden, quoted: false, location: scanner.errorLocation())
          }
        }
      } else {
        return nil
      }
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
      return List(children: atoms, quoted: endChar == "]", location: scanner.errorLocation()) // these [] lists can't be evaluated directly
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



