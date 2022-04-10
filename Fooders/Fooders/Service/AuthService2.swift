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

class AuthService2: ObservableObject {
  
  @Published var isLogin: Bool = false
  
    public static let shared = AuthService2()
    
    func isKakoLogin() async throws -> Bool {
        // 유효한 토큰이 있는지 검사한다.
        if (AuthApi.hasToken()) {
//            Task.init {
                do {
                    let tokenInfo: AccessTokenInfo = try await withCheckedThrowingContinuation { continuation in
                        UserApi.shared.accessTokenInfo { (accessTokenInfo, error) in
                            if let error = error {
                                continuation.resume(with: .failure(error))
                            } else if let accessTokenInfo = accessTokenInfo {
                                continuation.resume(with: .success(accessTokenInfo))
                            }
                        }
                    }
                  return true
                } catch {
                    if let sdkError = error as? SdkError, sdkError.isInvalidTokenError() == true {
                        return false
                    } else {
                        throw error
                    }
                }
//            }
        } else {
            return false
        }
    }
}


