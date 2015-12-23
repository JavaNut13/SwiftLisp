//
//  Builtins.swift
//  SwiftLisp
//
//  Created by Will Richardson on 23/12/15.
//  Copyright © 2015 JavaNut13. All rights reserved.
//

import Foundation

extension Space {
  func addBuiltins() {
    add("println") { namespace, args in
      print(args.map({ $0.run(namespace) }).map({ $0.show }).joinWithSeparator(" "))
      return Nil()
    }
    add("+") { _, args in
      return Num(value: args.reduce(0, combine: { $0 + ($1 as! Num).value }))
    }
    add("*") { _, args in
      return Num(value: args.reduce(1, combine: { $0 * ($1 as! Num).value }))
    }
    add("=") { namespace, args in
      let lhs = args[0].run(namespace)
      let rhs = args[1].run(namespace)
      if lhs.show == rhs.show {
        return lhs
      } else {
        return Nil()
      }
    }
    
    add("defn") { outerSpace, funcArgs in
      let name = (funcArgs.first! as! Identifier).value
      let argNames = ((funcArgs[1] as! Literal).value as! List).children.map({ ($0 as! Identifier).value })
      let theList = funcArgs[2] as! List
      outerSpace.add(name) { innerSpace, args in
        let oldArgValues = argNames.map({ ($0, innerSpace[$0]) })
        for (i, argName) in argNames.enumerate() {
          innerSpace[argName] = args[i].run(outerSpace)
        }
        let res = theList.run(innerSpace)
        for (argName, value) in oldArgValues {
          innerSpace[argName] = value
        }
        return res
      }
      return outerSpace[name]!
    }
    
    add("if") { namespace, args in
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
    
    add("eval") { space, args in
      if let arg = args.first?.run(space) as? Literal {
        return arg.value
      } else {
        return args.first!
      }
    }
  }
}