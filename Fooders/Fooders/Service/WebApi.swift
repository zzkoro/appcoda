//
//  WebApi.swift
//  Fooders
//
//  Created by junemp on 2022/04/09.
//

import Foundation

struct WebApi {
    static func Register(user: UserData, identityToken: Data?, authorizationCode: Data?) throws -> Bool {
        return true
    }
    
    static func Login(user: String, identityToken: Data?, authorizationCode: Data?) throws -> Bool {
        return true
    }
    
    static func Login(user: String, password: String) throws -> Bool {
        return true
    }
}
