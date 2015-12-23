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
      print(args.map({ $0.expand(namespace) }).map({ $0.show }).joinWithSeparator(" "))
      return Nil()
    }
    add("+") { space, args in
      let values = args.map({ ($0.expand(space) as! Num).value })
      return Num(value: values.reduce(0, combine: { $0 + $1 }))
    }
    add("*") { space, args in
      let values = args.map({ ($0.expand(space) as! Num).value })
      return Num(value: values.reduce(1, combine: { $0 * $1 }))
    }
    add("=") { namespace, args in
      let lhs = args[0].expand(namespace)
      let rhs = args[1].expand(namespace)
      if lhs.show == rhs.show {
        return lhs
      } else {
        return Nil()
      }
    }
    
    add("defn") { space, args in
      let name = (args.first! as! Identifier).value
      let listArgs = (args[1].expand(space) as! Literal).value as! List
      let code = args[2] as! List
      space[name] = Space.createFunction(name, space: space, args: listArgs, code: code)
      return Nil()
    }
    
    add("if") { namespace, args in
      let condition = args.first!.expand(namespace)
      let res: Atom
      if let _ = condition as? Nil { // it's false
        if args.count > 2 {
          res = args[2].expand(namespace)
        } else {
          res = Nil()
        }
      } else {
        res = args[1].expand(namespace)
      }
      return res
    }
    
    add("eval") { space, args in
      if let arg = args.first as? Literal {
        return arg.value.expand(space)
      } else {
        // TODO throw error - can't eval non-literal
        return Nil()
      }
    }
    
    add("fn") { space, args in
      let listArgs = (args[0].expand(space) as! Literal).value as! List
      let code = args[1] as! List
      return Space.createFunction("anonymous", space: space, args: listArgs, code: code)
    }
    add("map") { space, args in
      let fun = args.first!.expand(space) as! Function
      let list = ((args[1].expand(space) as! Literal).value as! List).children
      let result = list.map({ item in
        fun.run(space, args: [item.expand(space)])
      })
      return Literal(List(children: result))
    }
    add("filter") { space, args in
      let fun = args.first!.expand(space) as! Function
      let list = ((args[1].expand(space) as! Literal).value as! List).children
      let result = list.filter({ item in
        fun.run(space, args: [item.expand(space)]) as? Nil != nil
      })
      return Literal(List(children: result))
    }
    add("reduce") { space, args in
      let fun = args.first!.expand(space) as! Function
      let initial = args[1].expand(space)
      let list = ((args[2].expand(space) as! Literal).value as! List).children
      let result = list.reduce(initial, combine: { comb, item in
        fun.run(space, args: [comb, item.expand(space)])
      })
      return result
    }
    
//    add("cons") { space, args in
//      let
//    }
  }
  
  private static func createFunction(name: String, space: Space, args: List, code: List) -> Function {
    let argNames = args.children.map({ ($0 as! Identifier).value })
    let fun = Native(name: name, code: { innerSpace, args in
      let oldArgValues = argNames.map({ ($0, innerSpace[$0]) })
      for (i, argName) in argNames.enumerate() {
        innerSpace[argName] = args[i].expand(space)
      }
      let res = code.expand(innerSpace)
      for (argName, value) in oldArgValues {
        innerSpace[argName] = value
      }
      return res
    })
    return fun
  }
}