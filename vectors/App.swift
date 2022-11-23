//
//  vectorsApp.swift
//  vectors
//
//  Created by User on 18.11.22.
//

import SwiftUI

@main
struct vectorsApp: App {
    let game = VectorsGame()
    @StateObject private var dataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: game)
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
