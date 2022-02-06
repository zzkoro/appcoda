//
//  ContentView.swift
//  Fooders
//
//  Created by junemp on 2021/10/24.
//

import SwiftUI
import CoreData

struct RestaurantListView: View {
    
    @Environment(\.managedObjectContext) var context
    
    @FetchRequest(entity: Restaurant.entity(), sortDescriptors: [])
    var restaurants: FetchedResults<Restaurant>
    
    @State private var showNewRestaurant = false
    
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            List {
                if restaurants.count == 0 {
                    Image("emptydata")
                        .resizable()
                        .scaledToFit()
                    
                } else {
                
                    ForEach(restaurants.indices, id: \.self) { index in
        //                FullImageRow(restaurant: $restaurants[index])
                        
                        ZStack(alignment: .leading) {
                            NavigationLink(destination: RestaurantDetailView(restaurant: restaurants[index])) {
                                EmptyView()
                            }
                            .opacity(0)
                            BasicTextImageRow(restaurant: restaurants[index])
                        }
                        
                            .swipeActions(edge: .leading, allowsFullSwipe: false, content: {
                                
                                Button {
                                } label: {
                                    Image(systemName: "heart")
                                }
                                .tint(.green)
                                
                                Button {
                                } label: {
                                    Image(systemName: "square.and.arrow.up")
                                }
                                .tint(.orange)
                                
                               
                                
                            })
                        
                    }
                    .onDelete(perform: deleteRecord)
                   // .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Fooders")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle("")
//            .navigationBarHidden(true)
            .toolbar {
                Button(action: {
                    self.showNewRestaurant = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .accentColor(.primary)
        .sheet(isPresented: $showNewRestaurant) {
            NewRestaurantView()
        }
        .searchable(text: $searchText,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Search restaurants...") {
            Text("Thai").searchCompletion("Thaiw")
            Text("Cafe").searchCompletion("Cafed")
        }
        .onChange(of: searchText) { searchText in
            let predicate = searchText.isEmpty ? NSPredicate(value: true) : NSPredicate(format: "name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)
            
            restaurants.nsPredicate = predicate
            
        }
        .onOpenURL(perform: { url in
            switch url.path {
            case "/NewRestaurant": showNewRestaurant = true
            default: return
            }
        })
    }

    private func deleteRecord(indexSet: IndexSet) {
        for index in indexSet {
            let itemToDelete = restaurants[index]
            context.delete(itemToDelete)
        }
        
        DispatchQueue.main.async {
            do {
                try context.save()
            } catch {
                print(error)
            }
        }
    }
}


struct BasicTextImageRow: View {
    
    // MARK: - Binding
    
    @ObservedObject var restaurant: Restaurant
    
    // MARK: - State Variables
    
    @State private var showOptions = false
    @State private var showError = false
    
    @Environment(\.managedObjectContext) var context

    
    var body: some View {
        HStack(alignment: .top, spacing: 20){
            if let imageData = restaurant.image {
                Image(uiImage: UIImage(data: imageData) ?? UIImage())
                    .resizable()
                    .frame(width:120, height:118)
                    .cornerRadius(20)
    //                .clipShape(RoundedRectangle(cornerRadius: 20))
            
            }
            
            VStack(alignment: .leading) {
                Text(restaurant.name)
                    .font(.system(.title2, design: .rounded))
                
                Text(restaurant.type)
                    .font(.system(.body, design: .rounded))
                
                Text(restaurant.location)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.gray)
            }
            
            if restaurant.isFavorite {
                Spacer()
                
                Image(systemName: "heart.fill")
                    .foregroundColor(.yellow)
            }
            
        }
        .contextMenu {
            Button {
                self.showError.toggle()
            } label: {
                HStack {
                    Text("Reserve a table")
                    Image(systemName: "phone")
                }
            }
            
            Button {
                self.restaurant.isFavorite.toggle()
            } label: {
                HStack {
                    Text(restaurant.isFavorite ? "Remove from favorites" : "Mark as favorite")
                    Image(systemName: "heart")
                }
            }
            
            Button {
                self.showOptions.toggle()
            } label: {
                HStack {
                    Text("Share")
                    Image(systemName: "square.and.arrow.up")
                }
            }
            
            Button {
                self.context.delete(restaurant)
                try? self.context.save()
            } label: {
                HStack {
                    Text("Delete")
                    Image(systemName: "minus.circle")
                }
            }
        }
        .onChange(of: restaurant.isFavorite) { _ in
            if self.context.hasChanges {
                print("restaurant isFavorite save")
                try? self.context.save()
            }
        }
        .alert(isPresented: $showError) {
            Alert(title: Text("Not yet available"),
                  message: Text("Sorry, this feature is now available yet. Please retry later."),
                  primaryButton: .default(Text("OK")),
                  secondaryButton: .cancel())
        }
        .sheet(isPresented: $showOptions) {
            let defaultText = "Just checking in at \(restaurant.name)"
            
            if let imageData = restaurant.image, let imageToShare = UIImage(data: imageData) {
                ActivityView(activityItems: [defaultText, imageToShare])
            } else {
                ActivityView(activityItems: [defaultText])
            }
            
        }
    }
}

struct FullImageRow: View {
    
    @ObservedObject var restaurant: Restaurant
    
    @State private var showOptions = false
    @State private var showError = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10){
            if let imageData = restaurant.image {
                Image(uiImage: UIImage(data: imageData) ?? UIImage())
                    .resizable()
                    .scaledToFill()
                    .frame(height:200)
                    .cornerRadius(20)
            }
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text(restaurant.name)
                        .font(.system(.title2, design: .rounded))
                    
                    Text(restaurant.type)
                        .font(.system(.body, design: .rounded))
                    
                    Text(restaurant.location)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.gray)
                }
                if restaurant.isFavorite {
                    Spacer()
                    
                    Image(systemName: "heart.fill")
                        .foregroundColor(.yellow)
                }
            }
            
        }
        .onTapGesture {
            showOptions.toggle()
        }
        .actionSheet(isPresented: $showOptions) {
            var favoriteTitle = "Mark as favoriate"
            if restaurant.isFavorite {
                favoriteTitle = "Remove from favorites"
            }
            return ActionSheet(title: Text("What do you want to do?"),
                        message: nil,
                        buttons: [
                            .default(Text("Reserve a table")) {
                                self.showError.toggle()
                            },
                            .default(Text(favoriteTitle)) {
                                self.restaurant.isFavorite.toggle()
                                
                            },
                            .cancel()
                        ])
            
        }
        .alert(isPresented: $showError) {
            Alert(title: Text("Not yet available"),
                  message: Text("Sorry, this feature is now available yet. Please retry later."),
                  primaryButton: .default(Text("OK")),
                  secondaryButton: .cancel())
        }
    }
}

struct RestaurantListview_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantListView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        
//        RestaurantListView()
//            .preferredColorScheme(.dark)
//
//        BasicTextImageRow(imageName: "cafedeadend", name: "Cafe Deadend",
//       type: "Cafe", location: "Hong Kong", isFavorite: .constant(true))
//                   .previewLayout(.sizeThatFits)
//
//        FullImageRow(imageName: "cafedeadend", name: "Cafe Deadend", type:
//        "Cafe", location: "Hong Kong")
//                    .previewLayout(.sizeThatFits)
        
        
        
    }
}



