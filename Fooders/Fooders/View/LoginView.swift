//
//  LoginView.swift
//  Fooders
//
//  Created by junemp on 2022/03/16.
//

import SwiftUI
import KakaoSDKAuth
import KakaoSDKUser

struct LoginView: View {
    
    @StateObject var authService = AuthService()
    
    var body: some View {
            VStack {
//                Spacer()
                if authService.savedLogin == LoginType.none {
                    KakaoLoginButtonView()
                } else {
                    let savedLoginType = authService.savedLogin
                    Text("\(savedLoginType.rawValue) logined")
                }
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

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
