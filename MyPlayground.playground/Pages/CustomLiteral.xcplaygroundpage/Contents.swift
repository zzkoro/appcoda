//: [Previous](@previous)

import Foundation

var greeting = "Hello, playground"

//: [Next](@next)

extension Int: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = Int(value)!
    }
}

let x: Int = "A"

print(x is Int, x is String)
