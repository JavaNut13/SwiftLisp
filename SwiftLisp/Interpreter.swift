//
//  Interpreter.swift
//  SwiftLisp
//
//  Created by Will Richardson on 21/12/15.
//  Copyright © 2015 JavaNut13. All rights reserved.
//

import Foundation


protocol Function: Atom { // NATIVE FUNCTION
  func run(namespace: [String: Atom], args: [Atom]) -> Atom
}

struct Print: Function {
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
    return "N_print"
  }
}


extension Program {
  func run() {
    var global = [String: Atom]()
    global["println"] = Print()
    let lst = List(children: statements, quoted: false)
    lst.run(global)
  }
}