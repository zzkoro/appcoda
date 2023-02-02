//: [Previous](@previous)

import Foundation
import os

var greeting = "Hello, playground"

//: [Next](@next)


@MainActor final class ProductsViewModel: ObservableObject {
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier, category: ProductsViewModel.self)
    
    @Published private(set) var products: [Product] = []
    
    private let service: ProductService
    
    init(service: ProductService) {
        self.service = service
    }
    
    func fetch() async {
        do {
            Self.
        }
    }
    
}
