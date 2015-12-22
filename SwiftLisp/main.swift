//
//  main.swift
//  SwiftLisp
//
//  Created by Will Richardson on 21/12/15.
//  Copyright © 2015 JavaNut13. All rights reserved.
//

import Foundation

let pr = try! Program("(println (+ 1 2 3 4 5)) (println (- 5 (+ 5 6)))")

print(pr)

print("---")
pr.run()