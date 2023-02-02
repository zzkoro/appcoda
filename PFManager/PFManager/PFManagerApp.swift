//
//  PFManagerApp.swift
//  PFManager
//
//  Created by junemp on 2022/11/27.
//

import SwiftUI

@main
struct PFManagerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            DashboardView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
