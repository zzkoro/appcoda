//
//  DiscoverView.swift
//  Fooders
//
//  Created by junemp on 2022/01/31.
//

import SwiftUI
import CloudKit

struct DiscoverView: View {
    
    @StateObject private var cloudStore: RestaurantCloudStore = RestaurantCloudStore()
    @State private var showLoadingIndicator = false
    
    var body: some View {
        NavigationView {
            ZStack {
                List(cloudStore.restaurants, id: \.recordID) { restaurant in
                    HStack {
                        
                        AsyncImage(url: getImageURL(restaurant: restaurant)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Color.purple.opacity(0.1)
                        }
                        .frame(width: 50, height: 50)
                        .cornerRadius(10)
                        
                        Text(restaurant.object(forKey:"name") as! String)
                    }
                }
                .listStyle(PlainListStyle())
    //            .task {
    //                do {
    //                    try await cloudStore.fetchRestaurants()
    //                } catch {
    //                    print(error)
    //                }
    //            }
                .task {
                    cloudStore.fetchRestaurantsWithOperational {
                        showLoadingIndicator = false
                    }
                }
                .onAppear() {
                    showLoadingIndicator = true
                }
                .redacted(reason: showLoadingIndicator ? .placeholder : .init())
                
                if showLoadingIndicator {
                    ProgressView()
                }
            }
            .navigationTitle("Discover")
            .navigationBarTitleDisplayMode(.automatic)
        }
    }
    
    
    private func getImageURL(restaurant: CKRecord) -> URL? {
        guard let image = restaurant.object(forKey: "image"),
              let imageAsset = image as? CKAsset else {
                  return nil
              }
        return imageAsset.fileURL
    }
}

struct DiscoverView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverView()
    }
}
