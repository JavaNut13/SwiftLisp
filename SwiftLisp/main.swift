//
//  main.swift
//  SwiftLisp
//
//  Created by Will Richardson on 21/12/15.
//  Copyright © 2015 JavaNut13. All rights reserved.
//

import Foundation

let pr = Program()

pr.parse("(println \"hello\") (println (+ 6 7)) ('println) '(+ 3 five) [1 2 3]")