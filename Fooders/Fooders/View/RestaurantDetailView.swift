//
//  RestaurantDetailView.swift
//  Fooders
//
//  Created by junemp on 2021/10/25.
//

import SwiftUI
import Combine

struct RestaurantDetailView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var context
    
    @State private var showReview = false
    
    @ObservedObject var restaurant: Restaurant
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {

                Image(uiImage: UIImage(data: restaurant.image)!)
                    .resizable()
                    .scaledToFill()
                    .frame(minWidth:0, maxWidth: .infinity)
                    .overlay {
                        VStack {
                            Image(systemName: "heart")
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topTrailing)
                                .padding()
                                .font(.system(size: 30))
                                .foregroundColor(restaurant.isFavorite ? .yellow : .white)
//                                .background(.red)
                                .padding(.top, 0)
                                .frame(height: 60)

                            VStack(alignment: .leading, spacing: 5) {
                                Text(restaurant.name)
                                    .font(.custom("Nunito-Regular", size: 35
                                                  , relativeTo: .largeTitle))
                                    .bold()
                                Text(restaurant.type)
                                    .font(.system(.headline, design: .rounded))
                                    .padding(.all, 5)
//                                    .background(Color.black)

                            }
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .bottomLeading)
                            .foregroundColor(.white)
//                            .background(.green)
                            .padding()
                            
                            if let rating = restaurant.rating, !showReview {
                                VStack {
                                    Image(rating.image)
                                        .resizable()
                                        .frame(width:60, height:60)
//                                        .background(.red)
//                                        .padding([.bottom, .trailing])
                                        .transition(.scale)
                                }
                                
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 80, alignment: .topTrailing)
                                .padding([.trailing])
//                                .background(.green)
                                
                                
                            }
                        }
                        .animation(.spring(response: 0.2, dampingFraction: 0.3, blendDuration: 0.3), value: restaurant.rating)
                    }
                

                Text(restaurant.summary)
                    .padding()
                
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text("ADDRESS")
                            .font(.system(.headline, design: .rounded))

                        Text(restaurant.location)
                    }
                    .frame(minWidth:0, maxWidth: .infinity, alignment: .leading)

                    VStack(alignment: .leading) {
                        Text("PHONE")
                            .font(.system(.headline, design: .rounded))

                        Text(restaurant.phone)
                    }
                    .frame(minWidth:0, maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal)
                
                NavigationLink(destination:
                                MapView(location:restaurant.location).edgesIgnoringSafeArea(.all)) {
                    MapView(location: restaurant.location)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 200)
                        .cornerRadius(20)
                        .padding()
                }
            }
        
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
//            .navigationBarHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button (action: {
                        dismiss()
                    }) {
                        Text("\(Image(systemName: "chevron.left"))")
                    }
                    .opacity(self.showReview ? 0 : 1)
                }

            }
        }
   //     .ignoresSafeArea()
        .onChange(of:restaurant.rating) { _ in
            if self.context.hasChanges {
                print("restaurant save")
                try? self.context.save()
            }
        }
        .overlay {
            VStack {
                Spacer()
                Button(action: {
                    self.showReview.toggle()
                }) {
                    Text("Rate it")
                        .font(.system(.headline, design: .rounded))
                        .frame(minWidth: 0,maxWidth: .infinity)
                }
                .tint(Color("NavigationBarTitle"))
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: 25))
                .controlSize(.large)
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .overlay {
            self.showReview ?
            ZStack {
                ReviewView(isDisplayed: $showReview, restaurant: restaurant)
                    .navigationBarHidden(true)
                    .navigationBarTitle("")
            }
            : nil
        }
        
        
        
        
    }
}

struct RestaurantDetailView_Previews: PreviewProvider {
    
    
    
    static var previews: some View {
        
//        let restaurant: Restaurant = Restaurant(name: "Cafe Deadend", type: "Coffee & Tea Shop",
//                                                       location: "G/F, 72 Po Hing Fong, Sheung Wan, Hong Kong", phone: "232-923423",
//                                                       description: "Searching for great breakfast eateries and coffee? This place is for you. We open at 6:30 every morning, and close at 9 PM. We offer espresso and espresso based drink, such as capuccino, cafe latte, piccoloand many more. Come over and enjoy a great meal.", image: "cafedeadend", isFavorite: false, rating: Restaurant.Rating.awesome)
    
        
        NavigationView {
            RestaurantDetailView(restaurant:(PersistenceController.testData?.first)!)
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }

        .accentColor(.orange)
.previewInterfaceOrientation(.portraitUpsideDown)
    }
}
