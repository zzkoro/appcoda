//
//  MainView.swift
//  Fooders
//
//  Created by junemp on 2022/01/17.
//

import os
import SwiftUI
import Lottie
import KakaoSDKAuth

struct MainView: View {
    
    @State private var selectedTabIndex = 0
    @State private var showWalkthrough = false
    
    @State private var bottomSheetOpen = false
    @State private var bottomSheetShow = true
    
    @AppStorage("hasViewedWalkthrough") var hasViewedWalkthrough: Bool = false
    
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "someCategory")
    
    let dragGesture = DragGesture(minimumDistance: 5, coordinateSpace: .local)
        .onEnded({ value in
            if value.translation.width < 0 {
                print("left gesture")
            }

            if value.translation.width > 0 {
                print("right gesture")
            }

            if value.translation.height < 0 {
                print("up gesture")
            }

            if value.translation.height > 0 {
                print("down gesture")
            }
        })
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTabIndex) {
                RestaurantListView(bottomSheetShow: $bottomSheetShow)
                    .tabItem {
                        Label("Favorites", systemImage: "tag.fill")
                    }
                    .tag(0)

                DiscoverView()
                    .tabItem {
                        Label("Discover", systemImage: "wand.and.rays")
                    }
                    .tag(1)

                AboutView()
                    .tabItem {
                        Label("About", systemImage: "square.stack")
                    }
                    .tag(2)
                EventView()
                    .tabItem {
                        Label("Event", systemImage: "square.stack")
                    }
                    .tag(3)
                LoginView()
                    .tabItem {
                        Label("Login", systemImage: "square.stack")
                    }
                    .tag(4)
            }
            .tabViewStyle(backgroundColor: .blue.opacity(0.1), itemColor: .orange.opacity(0.8), selectedItemColor: Color("NavigationBarTitle"), badgeColor: .green)
            .sheet(isPresented: $showWalkthrough) {
                TutorialView()
            }
            .onAppear() {
                showWalkthrough = hasViewedWalkthrough ? false : true
                bottomSheetShow = showWalkthrough ? false : true
            }
            .onChange(of: selectedTabIndex) { index in
                if selectedTabIndex == 0 {
                    bottomSheetShow = true
                } else {
                    bottomSheetShow = false
                }
            }
            .onOpenURL(perform: { url in
                switch url.path {
                case "/OpenFavorites": selectedTabIndex = 0
                case "/OpenDiscover": selectedTabIndex = 1
                case "/NewRestaurant": selectedTabIndex = 0
                default: return
                }
            })
            .gesture(selectedTabIndex==10 ? dragGesture : nil)
             
            if bottomSheetShow {
                BottomSheetView(isOpen: $bottomSheetOpen, isShow: $bottomSheetShow, maxHeight: 500) {
                    Rectangle().fill(Color.red)
                }
                .transition(.move(edge: .bottom))
            }
        }

    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
