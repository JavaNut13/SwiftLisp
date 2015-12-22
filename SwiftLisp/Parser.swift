//
//  main.swift
//  SwiftLisp
//
//  Created by Will Richardson on 21/12/15.
//  Copyright © 2015 JavaNut13. All rights reserved.
//

import Foundation

protocol Atom: CustomStringConvertible {
  
}

struct Identifier: Atom {
  var value: String
  
  var description: String {
    return value
  }
}

struct List: Atom {
  let children: [Atom]
  
  var description: String {
    return "(" + children.map({ $0.description }).joinWithSeparator(" ") + ")"
  }
}

struct Program {
  func parse(input: String) {
    var scanner = Scanner(string: input)
    var atoms = [Atom]()
    while let atom = Program.parseAtom(&scanner) {
      atoms.append(atom)
      scanner.scanWhitespace()
    }
    print(atoms)
  }
  
  static func parseAtom(inout scanner: Scanner) -> Atom? {
    scanner.scanWhitespace()
    if scanner.pointingAt("(") || scanner.pointingAt("[") {
      return parseList(&scanner)
    } else {
      // These chars should terminate the atom
      if let iden = scanner.scanUpToCharacterOrEnd(" ", ")", "(", "[", "]") {
        return Identifier(value: iden)
      } else {
        return nil
      }
    }
  }
  
  static func parseList(inout scanner: Scanner) -> Atom? {
    scanner.scanWhitespace()
    if scanner.scanString("(") {
      var atoms = [Atom]()
      while let atom = parseAtom(&scanner) {
        atoms.append(atom)
      }
      if scanner.scanString(")") {
        return List(children: atoms)
      } else {
        return nil
      }
    } else if scanner.scanString("[") {
      var atoms = [Atom]()
      while let atom = parseAtom(&scanner) {
        atoms.append(atom)
      }
      if scanner.scanString("]") {
        return List(children: atoms)
      } else {
        return nil
      }
    } else {
      return nil
    }
  }
}



