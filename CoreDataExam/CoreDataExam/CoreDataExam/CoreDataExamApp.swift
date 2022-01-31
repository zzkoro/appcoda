//
//  CoreDataExamApp.swift
//  CoreDataExam
//
//  Created by junemp on 2022/01/31.
//

import SwiftUI

@main
struct CoreDataExamApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
