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
  
}

protocol Evaluatable: Atom {
  var noEvaluate: Bool { get set }
}

struct Identifier: Evaluatable {
  let value: String
  var noEvaluate: Bool
  
  var description: String {
    return (noEvaluate ? "'" : "") + value
  }
}

struct Str: Atom {
  let value: String
  
  var description: String {
    return "\"" + value + "\""
  }
}

struct Num: Atom {
  let value: Int
  
  var description: String {
    return String(value)
  }
}

struct List: Evaluatable {
  let children: [Atom]
  var noEvaluate: Bool
  
  var description: String {
    return (noEvaluate ? "'(" : "(") + children.map({ $0.description }).joinWithSeparator(" ") + ")"
  }
}

struct Program {
  func parse(input: String) {
    var scanner = Scanner(string: input)
    var atoms = [Atom]()
    do {
      while let atom = try Program.parseAtom(&scanner) {
        atoms.append(atom)
        scanner.scanWhitespace()
      }
    } catch {
      print(error)
    }
    print(atoms)
  }
  
  static func parseAtom(inout scanner: Scanner) throws -> Atom? {
    scanner.scanWhitespace()
    // Scan an array
    if scanner.pointingAt("(") || scanner.pointingAt("[") {
      return try parseList(&scanner)
    } else if scanner.pointingAt("\"") { // scan a string
      return try parseString(&scanner)
    } else if scanner.scanString("'") { // scan an identifier or number value
      let atom = try parseAtom(&scanner)
      if var eval = atom as? Evaluatable {
        eval.noEvaluate = true
        return eval
      } else {
        return atom
      }
    } else {
      // These chars should terminate the atom
      if let iden = scanner.scanUpToCharacterOrEnd([" ", ")", "(", "[", "]"]) {
        if let num = Int(iden) {
          return Num(value: num)
        } else {
          return Identifier(value: iden, noEvaluate: false)
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
      return List(children: atoms, noEvaluate: endChar == "]") // these [] lists can't be evaluated directly
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



