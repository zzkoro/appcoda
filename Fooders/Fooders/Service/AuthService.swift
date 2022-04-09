//
//  AuthService.swift
//  Fooders
//
//  Created by junemp on 2022/03/29.
//

import Foundation
import KakaoSDKAuth
import KakaoSDKUser
import KakaoSDKCommon

enum LoginType: String {
    case kakao
    case apple
    case none
}

class AuthService: ObservableObject {
    
    @Published private(set) var savedLogin:LoginType = LoginType.none
    @Published private(set) var isFetching = false
    
    private let store = AuthServiceStore()
    
    public init() {}
}

extension AuthService {
    @MainActor
    func fetchLogin() async throws {
        isFetching = true
        defer {
            isFetching = false
        }
        savedLogin = try await store.load()
        
        print("fetchLogin: \(savedLogin)")
        
    }
}

private actor AuthServiceStore {
    func load() async throws -> LoginType {
        // kakao login check
        if (AuthApi.hasToken()) {
            do {
                let _: AccessTokenInfo = try await withCheckedThrowingContinuation { continuation in
                    UserApi.shared.accessTokenInfo { (accessTokenInfo, error) in
                        if let error = error {
                            continuation.resume(with: .failure(error))
                        } else if let accessTokenInfo = accessTokenInfo {
                            continuation.resume(with: .success(accessTokenInfo))
                        }
                    }
                }
                return LoginType.kakao
            } catch {
                if let sdkError = error as? SdkError, sdkError.isInvalidTokenError() == true {
                    print("kakao invalid token")
                } else {
                    print("kakao access token check error: \(error.localizedDescription)")
                }
            }
        }
        return LoginType.none
    }
}


