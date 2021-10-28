//
//  ContentView.swift
//  StackViewDemo
//
//  Created by junemp on 2021/10/23.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    var body: some View {
        VStack(spacing: 20) {
            VStack {
                if #available(iOS 15.0, *) {
                    Text("Instant Developer")
                        .fontWeight(.medium)
                        .font(.system(size:40))
                        .foregroundColor(.indigo)
                } else {
                    // Fallback on earlier versions
                    Text("Instant Developerf")
                        .fontWeight(.medium)
                        .font(.system(size:40))
                        .foregroundColor(.blue)
                }
                
                Text("Get help from experts in 15 minutes")
            }
            
//            Image("user3")
//                .resizable()
//                .scaledToFit()
            HStack(alignment: .bottom, spacing: 20) {
                Image("student")
                    .resizable()
                    .scaledToFit()
                Image("tutor")
                    .resizable()
                .scaledToFit()
                
//                Image("user3")
//                    .resizable()
//                .scaledToFit()
            }
            .padding(.horizontal, 20)
            
            Text("Need help with coding problem? Register!")
            
            Spacer()
            
            if verticalSizeClass == .compact {
                HSignUpButtonGroup()
            } else {
                VSignUpButtonGroup()
            }
    
        }
        .padding(.top, 30)
        .background (
            Image("background")
                .resizable()
                .ignoresSafeArea()
        )
        
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 15.0, *) {
            ContentView()
                .previewDevice(PreviewDevice(rawValue: "iPhone 12 Pro"))
                .previewDisplayName("iPhone 12 Pro")
                .previewInterfaceOrientation(.portraitUpsideDown)
        } else {
            // Fallback on earlier versions
        }
    }
}

struct VSignUpButtonGroup: View {
    var body: some View {
        VStack {
            Button {
                
            } label: {
                Text("Sign Up")
            }
            .frame(width: 200)
            .padding()
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(10)
            
            Button {
                
            } label: {
                Text("Log In")
            }
            .frame(width: 200)
            .padding()
            .foregroundColor(.white)
            .background(Color.gray)
            .cornerRadius(10)
        }
    }
}

struct HSignUpButtonGroup: View {
    var body: some View {
        HStack {
            Button {
                
            } label: {
                Text("Sign Up")
            }
            .frame(width: 200)
            .padding()
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(10)
            
            Button {
                
            } label: {
                Text("Log In")
            }
            .frame(width: 200)
            .padding()
            .foregroundColor(.white)
            .background(Color.gray)
            .cornerRadius(10)
        }
    }
}
