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
import AuthenticationServices

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
        var savedLoginType: LoginType = LoginType.none
        
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
                savedLoginType = LoginType.kakao
            } catch {
                if let sdkError = error as? SdkError, sdkError.isInvalidTokenError() == true {
                    print("kakao invalid token")
                } else {
                    print("kakao access token check error: \(error.localizedDescription)")
                }
            }
        }
        
        // apple id login check
        // 1. keychain에 저장된 userData 정보를 가져온다.
        
        let userDataKeyChain = UserDataKeychain()
        do {
            let userData = try userDataKeyChain.retrieve()
            
            print("userData id: \(userData.identifier), email: \(userData.email)")
            
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let credentialState: ASAuthorizationAppleIDProvider.CredentialState = try await withCheckedThrowingContinuation { continuation in
                appleIDProvider.getCredentialState(forUserID: userData.identifier) { (credentialState, error) in
                    if let error = error {
                        continuation.resume(with: .failure(error))
                    } else {
                        continuation.resume(with: .success(credentialState))
                    }
                }
            }
            switch credentialState {
            case .authorized:
                print("해당 ID는 연동되어 있습니다.")
                savedLoginType = LoginType.apple
            case .revoked:
                print("해당 Apple ID는 연동되어 있지 않습니다.")
            case .notFound:
                print("해당 ID를 찾을 수 없습니다.")
            default:
                break
            }
        } catch {
            // apple login 정보가 없거나 상태 정보를 확인하지 못함
            print("error in getting apple id user data or get credential state: \(error.localizedDescription) ")
        }
        
        return savedLoginType
    }
}


