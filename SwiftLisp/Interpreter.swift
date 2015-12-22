//
//  Interpreter.swift
//  SwiftLisp
//
//  Created by Will Richardson on 21/12/15.
//  Copyright © 2015 JavaNut13. All rights reserved.
//

import Foundation


protocol Function { // NATIVE FUNCTION
  var name: String { get }
  func run(namespace: [String: Atom], args: [Atom]) -> Atom
}

struct Print: Function {
  let name = "println"
  var quoted = false
  
  func run(namespace: [String: Atom], args: [Atom]) -> Atom {
    var res = [String]()
    for arg in args {
      if let lst = arg as? List {
        res.append(lst.run(namespace).description)
      } else {
        res.append(arg.description)
      }
    }
    print(res.joinWithSeparator(" "))
    return Nil()
  }
  
  var description: String {
    return name
  }
}

struct Add: Function {
  let name = "+"
  var quoted = false
  
  func run(namespace: [String: Atom], args: [Atom]) -> Atom {
    var sum = 0
    for arg in args {
      if let lst = arg as? List {
        if let i = lst.run(namespace) as? Num {
          sum += i.value
        }
      } else if let i = arg as? Num {
        sum += i.value
      }
    }
    return Num(value: sum)
  }
  
  var description: String {
    return name
  }
}

struct Subtract: Function {
  let name = "-"
  var quoted = false
  
  func run(namespace: [String: Atom], args: [Atom]) -> Atom {
    let fst = (args.first! as! Num).value
    let lst = (args.last! as! Num).value
    return Num(value: fst - lst)
  }
  
  var description: String {
    return name
  }
}

extension List {
  func run(namespace: [String: Atom]) -> Atom {
    if quoted {
      var lst = self
      lst.quoted = false
      return lst
    }
    if let fun = children.first as? Function {
      return fun.run(namespace, args: Array(children.dropFirst(1)))
    } else if let iden = children.first as? Identifier, let fun = namespace[iden.value] as? Function {
      return fun.run(namespace, args: Array(children.dropFirst(1)))
    } else {
      var res = [Atom]()
      for child in children {
        if let lst = child as? List {
          res.append(lst.run(namespace))
        } else {
          res.append(child)
        }
      }
      return List(children: res, quoted: true)
    }
  }
}


extension Program {
  func run() {
    let global = register([Print(), Add(), Subtract()])
    let lst = List(children: statements, quoted: false)
    lst.run(global)
  }
  
  func register(funcs: [Function]) -> [String: Atom] {
    var global = [String: Atom]()
    for fun in funcs {
      global[fun.name] = fun
    }
    return global
  }
}