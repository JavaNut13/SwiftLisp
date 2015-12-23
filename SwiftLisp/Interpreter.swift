//
//  Interpreter.swift
//  SwiftLisp
//
//  Created by Will Richardson on 21/12/15.
//  Copyright © 2015 JavaNut13. All rights reserved.
//

import Foundation

class Space: CustomStringConvertible {
  var assignments = [String: Atom]()
  
  init() {
    addBuiltins()
  }
  
  subscript(key: String) -> Atom? {
    get {
      return assignments[key]
    }
    set {
      assignments[key] = newValue
    }
  }
  
  func add(name: String, code: (space: Space, args: [Atom]) -> Atom) {
    assignments[name] = Native(name: name, code: code)
  }
  
  var description: String {
    return assignments.description
  }
}

protocol Function: Atom {
  func run(space: Space, args: [Atom]) -> Atom
}

struct Native: Function {
  var quoted = false
  let description: String
  let location: ErrorLocation? = nil
  
  private let code: (namespace: Space, args: [Atom]) -> Atom
  
  init(name: String, code: (namespace: Space, args: [Atom]) -> Atom) {
    self.code = code
    description = name
  }
  
  func run(namespace: Space, args: [Atom]) -> Atom {
    return code(namespace: namespace, args: args)
  }
  
  func run(namespace: Space) -> Atom {
    return self
  }
  var show: String {
    return description
  }
}

extension List {
  func run(space: Space) -> Atom {
    if let first = children.first?.run(space) {
      if let fun = first as? Function {
        return fun.run(space, args: Array(children.dropFirst(1)))
      } else if let iden = first as? Identifier {
        if let fun = space[iden.value] as? Function {
          return fun.run(space, args: Array(children.dropFirst(1)))
        } else {
          // TODO throw an error here
          return Nil()
        }
      } else if children.count > 1 {
        return children.dropFirst(1).map({ $0.run(space) }).last!
      } else {
        return first
      }
    } else {
      return Nil()
    }
  }
}


extension Program {
  func run() {
    let global = Space()
    statements.forEach({ $0.run(global) })
  }
}



