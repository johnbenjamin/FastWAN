//
//  ErrorUtility.swift
//  FastWAN
//
//  Created by Xeon on 2022/7/28.
//

import Foundation

class ErrorUtility {
  public static func areEqual(_ lhs: Error, _ rhs: Error) -> Bool {
    return lhs.reflectedString == rhs.reflectedString
  }
}

public extension Error {
  var reflectedString: String {
    return String(reflecting: self)
  }

  func isEqual(to: Self) -> Bool {
    return reflectedString == to.reflectedString
  }
}

public extension NSError {
  func isEqual(to: NSError) -> Bool {
    let lhs = self as Error
    let rhs = to as Error
    return isEqual(to) && lhs.reflectedString == rhs.reflectedString
  }
}
