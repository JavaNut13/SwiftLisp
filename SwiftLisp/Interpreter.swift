//
//  Interpreter.swift
//  SwiftLisp
//
//  Created by Will Richardson on 21/12/15.
//  Copyright © 2015 JavaNut13. All rights reserved.
//

import Foundation

class Namespace {
  var functions = [String: Atom]()
  
  func add(name: String, code: (namespace: Namespace, args: [Atom]) -> Atom) {
    functions[name] = Native(name: name, code: code)
  }
}

protocol Function: Atom {
  func run(namespace: Namespace, args: [Atom]) -> Atom
}

struct Native: Function {
  var quoted = false
  let description: String
  private let code: (namespace: Namespace, args: [Atom]) -> Atom
  
  init(name: String, code: (namespace: Namespace, args: [Atom]) -> Atom) {
    self.code = code
    description = name
  }
  
  func run(namespace: Namespace, args: [Atom]) -> Atom {
    return code(namespace: namespace, args: args)
  }
  
  func run(namespace: Namespace) -> Atom {
    return self
  }
}

extension List {
  func run(namespace: Namespace) -> Atom {
    if quoted {
      var lst = self
      lst.quoted = false
      return lst
    }
    let runChildren = children.map({ $0.run(namespace) })
    if let fun = runChildren.first as? Function {
      return fun.run(namespace, args: Array(runChildren.dropFirst(1)))
    } else {
      return List(children: runChildren, quoted: true)
    }
  }
}


extension Program {
  func run() {
    let global = Namespace()
    global.add("println") { _, args in
      print(args.map({ $0 as? Str == nil ? $0.description : ($0 as! Str).value }).joinWithSeparator(" "))
      return Nil()
    }
    global.add("+") { _, args in
      return Num(value: args.reduce(0, combine: { $0 + ($1 as! Num).value }))
    }
    let lst = List(children: statements, quoted: false)
    lst.run(global)
  }
}



