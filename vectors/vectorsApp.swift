//
//  vectorsApp.swift
//  vectors
//
//  Created by User on 18.11.22.
//

import SwiftUI

@main
struct vectorsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
