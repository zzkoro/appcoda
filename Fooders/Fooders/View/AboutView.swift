//
//  AboutView.swift
//  Fooders
//
//  Created by junemp on 2022/01/16.
//

import SwiftUI

struct AboutView: View {
    
    @State private var link: WebLink?
    
    @ObservedObject var viewModel = WebViewModel()
    @State var bar = true
    
    enum WebLink: String, Identifiable {
        var id: UUID {
            UUID()
        }
        
        case rateUs = "https://www.apple.com/ios/app-store"
        case feedback = "https://www.appcoda.com/contact"
        case twitter = "https://www.twitter.com/appcodamobile"
        case facebook = "https://www.facebook.com/appcodamobile"
        case instagram = "https://www.instagram.com/appcodadotcom"
        case local = "http://127.0.0.1:5500/project/index.html"
    }
    
    var body: some View {
        NavigationView {
            List {
                Image("about")
                    .resizable()
                    .scaledToFit()
                
                Section {
                    
                    Link(destination: URL(string: WebLink.rateUs.rawValue)!, label: {
                        Label("Rate us on App Store", image: "store")
                            .foregroundColor(.primary)
                    })
                    
                    Label(String(localized: "Tell us your feedback", comment: "Tell us your feedback"), image: "chat")
                        .onTapGesture {
                            link = .feedback
                        }
                }
                
                Section {
                    Label("Twitter", image: "twitter")
                        .onTapGesture {
                            link = .twitter
                        }
                    Label("Facebook", image: "facebook")
                        .onTapGesture {
                            link = .facebook
                        }
                    Label("Instagram", image: "instagram")
                        .onTapGesture {
                            link = .instagram
                        }
                    Label("Local", image: "instagram")
                        .onTapGesture {
                            link = .local
                        }
                }
            }
            .sheet(item: $link) { item in
                if let url = URL(string: item.rawValue) {
                     WebView(url: url, viewModel: viewModel)
                    // SafariView(url: url)
                    HStack {
                        Text(bar ? "Before" : "After")
                        Button(action: {
                            self.viewModel.foo.send(true)
                            
                            
                        }) {
                            Text("보내기")
                        }
                        Button(action: {
                            link = nil
                            
                        }) {
                            Text("닫기")
                        }
                    }
                }
            }
            .onReceive(self.viewModel.bar.receive(on: RunLoop.main)) { value in
                self.bar = value
                print("bar received: \(self.bar)")
            }
            .listStyle(GroupedListStyle())
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
            .environment(\.locale, .init(identifier: "de"))
    }
}
