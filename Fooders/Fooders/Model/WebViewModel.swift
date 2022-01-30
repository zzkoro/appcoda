//
//  WebViewModel.swift
//  Fooders
//
//  Created by junemp on 2022/01/23.
//

import Foundation
import Combine

class WebViewModel: ObservableObject {
    var foo = PassthroughSubject<Bool, Never>() // App -> Web
    var bar = PassthroughSubject<Bool, Never>() // Web -> App
}
