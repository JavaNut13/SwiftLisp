//
//  Error.swift
//  SwiftLisp
//
//  Created by Will Richardson on 22/12/15.
//  Copyright © 2015 JavaNut13. All rights reserved.
//

import Foundation

struct ErrorLocation {
  let row: Int
  let column: Int
}

protocol ErrorLocatable {
  var location: ErrorLocation? { get }
}

enum SyntaxError: ErrorType {
  case UnexpectedParen(ErrorLocation?)
  case ExpectedParen(ErrorLocation?)
  case ExpectedQuote(ErrorLocation?)
}

enum RuntimeError: ErrorType {
  case UnknownIdentifier(ErrorLocation?)
  case UnexpectedType(ErrorLocation?)
}

