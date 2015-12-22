//
//  main.swift
//  SwiftLisp
//
//  Created by Will Richardson on 21/12/15.
//  Copyright © 2015 JavaNut13. All rights reserved.
//

import Foundation

enum SyntaxError: ErrorType {
  case UnexpectedParen(line: Int, col: Int)
  case ExpectedParen(line: Int, col: Int)
  case ExpectedQuote(line: Int, col: Int)
  case UnknownIdentifier(line: Int, col: Int)
}

protocol Atom: CustomStringConvertible {
  var quoted: Bool { get set }
  func run(namespace: Namespace) -> Atom
}

struct Identifier: Atom {
  let value: String
  var quoted: Bool
  
  func run(namespace: Namespace) -> Atom {
    if let v = namespace.functions[value] {
      return v
    } else {
      return Nil()
    }
  }
  
  var description: String {
    return (quoted ? "'" : "") + value
  }
}

struct Str: Atom {
  let value: String
  var quoted: Bool
  
  init(value: String) {
    self.value = value
    quoted = false
  }
  
  func run(namespace: Namespace) -> Atom {
    return self
  }
  
  var description: String {
    return "\"" + value + "\""
  }
}

struct Num: Atom {
  let value: Int
  var quoted: Bool
  
  init(value: Int) {
    self.value = value
    quoted = false
  }
  
  func run(namespace: Namespace) -> Atom {
    return self
  }
  
  var description: String {
    return String(value)
  }
}

struct Nil: Atom {
  var quoted = false
  
  func run(namespace: Namespace) -> Atom {
    return self
  }
  
  var description: String {
    return "nil"
  }
}

struct List: Atom {
  let children: [Atom]
  var quoted: Bool
  
  var description: String {
    return (quoted ? "'(" : "(") + children.map({ $0.description }).joinWithSeparator(" ") + ")"
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
          return Num(value: num)
        } else {
          if iden == "nil" {
            return Nil()
          } else {
            return Identifier(value: iden, quoted: false)
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
      return List(children: atoms, quoted: endChar == "]") // these [] lists can't be evaluated directly
    } else {
      throw SyntaxError.ExpectedParen(line: scanner.row, col: scanner.col)
    }
  }
  
  static func parseString(inout scanner: Scanner) throws -> Str? {
    scanner.scanWhitespace()
    if scanner.scanString("\"") {
      if let iden = scanner.scanUpToCharacter(["\""]) {
        scanner.scanString("\"")
        return Str(value: iden)
      } else {
        throw SyntaxError.ExpectedQuote(line: scanner.row, col: scanner.col)
      }
    } else {
      return nil
    }
  }
}



