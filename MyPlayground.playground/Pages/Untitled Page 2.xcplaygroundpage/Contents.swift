//: [Previous](@previous)

import Foundation

protocol Vehicle {
    func travel(to destination: String)
}

struct Car: Vehicle {
    func travel(to destination: String) {
        print("I'm driving to \(destination)")
    }
    
    
}

func travel<T: Vehicle>(to destinations: [String], using vehicle: T) {
    for destination in destinations {
        vehicle.travel(to: destination)
    }
}

travel(to: ["London", "Amarillo"], using: vehicle)

func travel2(to destinations: [String], using vehicle: Vehicle) {
    for destination in destinations {
        vehicle.travel(to: destination)
    }
}

let vehicle = Car()
vehicle.travel(to: "London")

travel2(to: ["London", "Amarillo"], using: vehicle)

//let vehicle3: any Vehicle = Car()

