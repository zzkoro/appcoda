//
//  ContentView.swift
//  Fooders
//
//  Created by junemp on 2021/10/24.
//

import os
import SwiftUI
import CoreData
//import Introspect

struct RestaurantListView: View {
    
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "someCategory")
    
    @Environment(\.managedObjectContext) var context
    
    @FetchRequest(entity: Restaurant.entity(), sortDescriptors: [])
    var restaurants: FetchedResults<Restaurant>
    
    @State private var showNewRestaurant = false
    @State private var searchText = ""
    
    @State var observation: NSKeyValueObservation?
    @State var navigationController: UINavigationController?
    @State var tabbarController: UITabBarController?
    
    @Binding var bottomSheetShow: Bool
    
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
//            .introspectTabBarController {
//                tabbarController = $0
//            }
//            .introspectNavigationController {
//                navigationController = $0
//            }
//            .introspectTableView { tableView in
//                observation = tableView.observe(\.contentOffset) { tableView, change in
//                    let transY = tableView.panGestureRecognizer.translation(in: tableView).y
//                    print("y: \(transY)")
//                    if transY != 0 {
//                        bottomSheetShow = false
//                    }
//                    if (transY < 0) {
//                        navigationController?.setNavigationBarHidden(true, animated: true)
//                        tabbarController?.tabBar.isHidden = false
//                    } else {
//                        navigationController?.setNavigationBarHidden(false, animated: true)
//                        tabbarController?.tabBar.isHidden = true
//                    }
//                    
//                }
//            }
            .listStyle(.plain)
            .navigationTitle("Fooders")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle("")
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
                    placement: .navigationBarDrawer(displayMode: .automatic),
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
        .task {
            prepareNotification()
        }
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
    
    private func prepareNotification() {
        if restaurants.count <= 0 {
            logger.log("restaurant count is zero")
            return
        }
        
        let ramdomNum = Int.random(in: 0..<restaurants.count)
        let suggestedRestaurant = restaurants[ramdomNum]
        
        // create the user notification
        let content = UNMutableNotificationContent()
        content.title = "레스토랑 추천"
        content.subtitle = "새로운 음식을 먹어보세요"
        content.body = "\(suggestedRestaurant.name) 레스토랑을 추천합니다. 이 레스토랑 위치는 \(suggestedRestaurant.location)입니다."
        content.sound = UNNotificationSound.default
        content.userInfo = ["phone": suggestedRestaurant.phone]
        
        // Adding the image
        let tempDirURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let tempFileURL = tempDirURL.appendingPathComponent("suggested-restaurant.jpg")
        
        logger.log("tempFileURL is \(tempFileURL)")
        
        if let image = UIImage(data: suggestedRestaurant.image as Data) {
            try? image.jpegData(compressionQuality: 1.0)?.write(to: tempFileURL)
            if let restaurantImage = try? UNNotificationAttachment(identifier: "restaurantImage", url: tempFileURL, options: nil) {
                content.attachments = [restaurantImage]
            }
        }
        
        // Adding actions
        let categoryIdentifier = "fooders.restaurantaction"
        let makeReservationAction = UNNotificationAction(identifier: "fooders.makeReservation", title: "자리예약하기", options: [.foreground])
        let cancelAction = UNNotificationAction(identifier: "fooders.cancel", title: "나중에", options: [])
        let category = UNNotificationCategory(identifier: categoryIdentifier, actions: [makeReservationAction, cancelAction], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        content.categoryIdentifier = categoryIdentifier
        
        // Adding trigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: "fooders.restaurantSuggestion", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
        logger.log("fooders.restaurantSuggestion notification registered!!")
        
    }
}

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
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
        RestaurantListView(bottomSheetShow: .constant(false))
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



