//: [Previous](@previous)

import Foundation

var greeting = "Hello, playground"

//: [Next](@next)

let oneTwoThree = 1...3
for number in oneTwoThree {
    print(number)
}

struct KumjipIterator: IteratorProtocol {
    typealias Element = Int
    var current = 1
    
    mutating func next() -> Element? {
        defer { current += 1 }
        return current
    }
}

struct Kumjip: Sequence {
    
    func makeIterator() -> some IteratorProtocol {
        return KumjipIterator()
    }
}

let kumjip = Kumjip()

for value in kumjip {}
