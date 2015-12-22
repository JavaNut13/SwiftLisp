//
//  main.swift
//  SwiftLisp
//
//  Created by Will Richardson on 21/12/15.
//  Copyright © 2015 JavaNut13. All rights reserved.
//

import Foundation

let input = try! String(contentsOfFile: "/Users/will/Desktop/main.lisp")

let pr = try! Program(input)

print(pr)

print("---")
pr.run()