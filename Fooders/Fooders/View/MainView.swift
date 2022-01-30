//
//  MainView.swift
//  Fooders
//
//  Created by junemp on 2022/01/17.
//

import SwiftUI

struct MainView: View {
    
    @State private var selectedTabIndex = 0
    
    var body: some View {
        TabView(selection: $selectedTabIndex) {
            RestaurantListView()
                .tabItem {
                    Label("Favorites", systemImage: "tag.fill")
                }
                .tag(0)
            
            Text("Discover")
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
        }
        //        .onAppear() {
        //            //UITabBar.appearance().barTintColor = .orange.opacity(0.95)
        //
        //        }
        //        .accentColor(Color("NavigationBarTitle"))
        .tabViewStyle(backgroundColor: .blue.opacity(0.1), itemColor: .orange.opacity(0.8), selectedItemColor: Color("NavigationBarTitle"), badgeColor: .green)

    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
