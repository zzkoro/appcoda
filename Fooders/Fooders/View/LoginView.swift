//
//  LoginView.swift
//  Fooders
//
//  Created by junemp on 2022/03/16.
//

import SwiftUI
import KakaoSDKAuth
import KakaoSDKUser
import AuthenticationServices

struct LoginView: View {
    @Environment(\.window) var window: UIWindow?
    
    @StateObject var authService = AuthService()
    @State var appleSignInDelegates: SignInWithAppleDelegates! = nil
    
    
    var body: some View {
            VStack {
//                Spacer()
//                if authService.savedLogin == LoginType.none {
                    KakaoLoginButtonView()
                    SignInWithAppleView()
                        .frame(width: 280, height: 60)
                        .onTapGesture(perform: showAppleLogin)
//                } else {
//                    let savedLoginType = authService.savedLogin
//                    Text("\(savedLoginType.rawValue) logined")
//                }
            }
            .task {
                try? await authService.fetchLogin()
            }
            .opacity(authService.isFetching ? 0 : 1)
            .overlay {
                if authService.isFetching {
                    ProgressView()
                }
            }
            .onAppear {
                // 화면에 들어서자 마자 자동으로 apple id 로그인창을 띄워줌
//                self.performExistingAccountSetupFlows()
            }
    }
    
    private func showAppleLogin() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        performSignIn(using: [request])
    }
    
    private func performSignIn(using requests: [ASAuthorizationRequest]) {
        
        print("performSignIn")
        
        appleSignInDelegates = SignInWithAppleDelegates(window: window) { success in
            if success {
                print("performSignIn success")
            } else {
                print("performSignIn error")
            }
        }
        
        
        let controller = ASAuthorizationController(authorizationRequests: requests)
        controller.delegate = appleSignInDelegates
        controller.presentationContextProvider = appleSignInDelegates
        
        print("before performRequests")
        
        controller.performRequests()
        
        print("after performRequests")
    }
    
    private func performExistingAccountSetupFlows() {
        
        print("performExistingAccountSetupFlows")
        
        let requests = [
            ASAuthorizationAppleIDProvider().createRequest(),
            ASAuthorizationPasswordProvider().createRequest()
        ]
        
        performSignIn(using: requests)
    }
    
    
}

struct KakaoLoginButtonView: View {
    var body: some View {
        Button {
            //카카오톡이 설치되어 있는지 확인
            if (UserApi.isKakaoTalkLoginAvailable()) {
                //카카오톡을 통해 로그인
                print("start loginWithKakoTalk")
                UserApi.shared.loginWithKakaoTalk { (oauthToken, error) in
                    print("oauth:\(String(describing: oauthToken))")
                    print("error: \(String(describing: error))")
                }
            } else {
                //카카오 계정으로 로그인
                UserApi.shared.loginWithKakaoAccount { (oauthToken, error) in
                    print(oauthToken)
                    print(error)
                }
            }
        } label: {
            Image("kakao_login_large_wide")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width : UIScreen.main.bounds.width * 0.9)
        }
    }
}

final class SignInWithAppleView: UIViewRepresentable {
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        return ASAuthorizationAppleIDButton()
    }
    
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
