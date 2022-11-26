//
//  vectorsApp.swift
//  vectors
//
//  Created by User on 18.11.22.
//

import SwiftUI
import CoreData

@main
struct vectorsApp: App {
    @StateObject private var dataController = DataController()
    let game = VectorsGame()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: game)
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
