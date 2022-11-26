//
//  DataController.swift
//  vectors
//
//  Created by User on 25.11.22.
//

import Foundation
import CoreData

class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "VectorData")
    
    init() {
        container.loadPersistentStores {description, error in
            if let error = error {
                print("CoreData failed to load: \(error.localizedDescription)")
            }
        }
    }
}
