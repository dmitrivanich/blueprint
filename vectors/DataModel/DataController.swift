//
//  DataController.swift
//  vectors
//
//  Created by User on 24.11.22.
//

import Foundation
import CoreData

class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "VectorModel")
    
    init() {
        container.loadPersistentStores{ desc, error in
            if let error = error {
                print("Failed to load the data \(error.localizedDescription)")
            }
        }
    }
    
    func save(context: NSManagedObjectContext) {
        do {
            try context.save()
            print("saved")
        } catch {
            print("error saving the data")
        }
    }
    
    func addVector(name: String, context: NSManagedObjectContext) {
        let vector = Vector(context: context)
        vector.id = UUID()
        vector.name = name
        
        save(context: context)
    }
    
    func editVector(vector: Vector, name: String, context: NSManagedObjectContext){
        vector.name = name
        
        save(context: context)
    }
}

