import UIKit
import SwiftUI
import Combine

@propertyWrapper
struct WhateverDouble {
    
    private(set) var value: Int = 0
    private(set) var prjValue: Int = 0
    
    private var maximum: Int = 0
    
    var wrappedValue: Int {
        get { value }
        set { value = newValue*2 }
    }
    
    var projectedValue: Int {
        get { return prjValue }
        set { prjValue = newValue }
    }
    
    init(wrappedValue: Int) {
        value = wrappedValue*2
    }
    
    init(maximum: Int) {
        self.maximum = maximum
    }
}

struct UserInfo {
    @WhateverDouble(maximum: 10)
    var age: Int
    
    @Environment(\.isPresented) var isPresented: Bool
}

var userInfo = UserInfo()

print(userInfo.age)
print(userInfo.isPresented)


userInfo.age = 30

print(userInfo.age)

userInfo.$age = 50

print(userInfo.$age)

struct User: Equatable {
    var name: String
}


class ImperativeUserManager {
    private(set) var currentUser: User? {
        didSet {
            if oldValue != currentUser {
                NotificationCenter.default.post(name: NSNotification.Name("userStateDidChange"), object: nil)
            }
        }
    }
    
    var userIsLoggedIn: Bool {
        currentUser != nil
    }
    
}

class ReactiveUserManager1: ObservableObject {
    @Published private(set) var currentUser: User? {
        didSet {
            userIsLoggedIn = currentUser != nil
        }
    }
    @Published private(set) var userIsLoggedIn: Bool = false
}

class ReactiveUserManager2: ObservableObject {
    @Published private(set) var currentUser: User?
    @Published private(set) var userIsLoggedIn: Bool = false
        
    private var subscribers = Set<AnyCancellable>()
    
    init() {
        $currentUser
            .map { $0 != nil }
            .assign(to: \.userIsLoggedIn, on: self)
            .store(in: &subscribers)
    
    }
}

import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Hello, world!")
    }
}




