//
//  SignInWithAppleDelegates.swift
//  Fooders
//
//  Created by junemp on 2022/04/09.
//

import Foundation
import UIKit
import AuthenticationServices
import SwiftUI

class SignInWithAppleDelegates: NSObject {
    private let signInSucceeded: (Bool) -> Void
    private weak var window: UIWindow!
    
    init(window: UIWindow?, onSignedIn: @escaping (Bool) -> Void) {
        self.window = window
        self.signInSucceeded = onSignedIn
    }
}

extension SignInWithAppleDelegates: ASAuthorizationControllerDelegate {
    
    private func registerNewAccount(credential: ASAuthorizationAppleIDCredential) {
        
 
        let userData = UserData(email: credential.email!, name: credential.fullName!, identifier: credential.user)
        
        let keychain = UserDataKeychain()
        do {
            try keychain.store(userData)
            
            print("store userData: \(userData)")
            
        } catch {
            print("error in storing userData. error:\(error.localizedDescription)")
            
            let keyChainError = error as! KeychainError
            
            print("error in storing userData: \(userData), error:\(keyChainError)")
            self.signInSucceeded(false)
        }
        
        do {
            let success = try WebApi.Register(user: userData, identityToken: credential.identityToken, authorizationCode: credential.authorizationCode)
            self.signInSucceeded(success)
        } catch {
            self.signInSucceeded(false)
        }
    }
    
    private func signInWithExistingAccount(credential: ASAuthorizationAppleIDCredential) {
        do {
            let success = try WebApi.Login(user: credential.user, identityToken: credential.identityToken, authorizationCode: credential.authorizationCode)
            self.signInSucceeded(success)
        } catch {
            // keychain에서 사용자 정보를 가져와 서버에 다시 등록한다.
            // ...
            self.signInSucceeded(true)
        }
    }
    
    private func signInWithUserAndPassword(credential: ASPasswordCredential) {
        do {
            let success = try WebApi.Login(user: credential.user, password: credential.password)
            self.signInSucceeded(success)
        } catch {
            self.signInSucceeded(true)
        }
    }
    
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIdCredential as ASAuthorizationAppleIDCredential:
            if let _ = appleIdCredential.email, let _ = appleIdCredential.fullName {
                // register new account
                registerNewAccount(credential: appleIdCredential)
            } else {
                // sign in with existing account
                signInWithExistingAccount(credential: appleIdCredential)
            }
            break
        case let passwordCredential as ASPasswordCredential:
            // sign in with user and password
            signInWithUserAndPassword(credential: passwordCredential)
            break
        default:
            break
        }
    }
    
}

extension SignInWithAppleDelegates: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.window
    }
}
