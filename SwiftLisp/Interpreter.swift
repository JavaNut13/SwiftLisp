//
//  Interpreter.swift
//  SwiftLisp
//
//  Created by Will Richardson on 21/12/15.
//  Copyright © 2015 JavaNut13. All rights reserved.
//

import Foundation

class Namespace: CustomStringConvertible {
  var assignments = [String: Atom]()
  
  subscript(key: String) -> Atom? {
    get {
      return assignments[key]
    }
    set {
      assignments[key] = newValue
    }
  }
  
  func add(name: String, code: (namespace: Namespace, args: [Atom]) -> Atom) {
    assignments[name] = Native(name: name, code: code)
  }
  
  var description: String {
    return assignments.description
  }
}

protocol Function: Atom {
  func run(namespace: Namespace, args: [Atom]) -> Atom
}

struct Native: Function {
  var quoted = false
  let description: String
  let location: ErrorLocation? = nil
  
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
  var show: String {
    return description
  }
}

extension List {
  func run(namespace: Namespace) -> Atom {
    if quoted {
      var lst = self
      lst.quoted = false
      return lst
    }
//    let runChildren = children.map({ $0.run(namespace) })
    if let first = children.first?.run(namespace) {
      if let fun = first as? Function where !fun.quoted {
        return fun.run(namespace, args: Array(children.dropFirst(1)))
      } else if children.count > 1 {
        return children.dropFirst(1).map({ $0.run(namespace) }).last!
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
    let global = Namespace()
    global.add("println") { namespace, args in
      print(args.map({ $0.run(namespace) }).map({ $0.show }).joinWithSeparator(" "))
      return Nil()
    }
    global.add("+") { _, args in
      return Num(value: args.reduce(0, combine: { $0 + ($1 as! Num).value }))
    }
    global.add("*") { _, args in
      return Num(value: args.reduce(1, combine: { $0 * ($1 as! Num).value }))
    }
    global.add("=") { namespace, args in
      let lhs = args[0].run(namespace)
      let rhs = args[1].run(namespace)
      if lhs.show == rhs.show {
        return lhs
      } else {
        return Nil()
      }
    }
    
    global.add("defn") { namespace, args in
      let name = (args.first! as! Identifier).value
      let argNames = (args[1] as! List).children.map({ ($0 as! Identifier).value })
      let theList = args[2] as! List
      namespace.add(name) { space, passed in
        let tmpStore = argNames.map({ ($0, space[$0]) })
        for (i, argName) in argNames.enumerate() {
          space[argName] = passed[i].run(namespace)
        }
        let res = theList.run(space)
        for (argName, value) in tmpStore {
          space[argName] = value
        }
        return res
      }
      return namespace[name]!
    }
    
    global.add("if") { namespace, args in
      let condition = args.first!.run(namespace)
      let res: Atom
      if let _ = condition as? Nil { // it's false
        if args.count > 2 {
          res = args[2].run(namespace)
        } else {
          res = Nil()
        }
      } else {
        res = args[1].run(namespace)
      }
      return res
    }
    statements.forEach({ $0.run(global) })
  }
}



