//
//  DataController.swift
//  vectors
//
//  Created by User on 25.11.22.
//

import Foundation
import CoreData
import UIKit

class VectorModel: NSObject, NSCoding {
    var id: Int = .zero
    var startX: Int = .zero
    var startY: Int = .zero
    var endX: Int = .zero
    var endY: Int = .zero
    var color: UIColor = UIColor(.black)
    var chosen: Bool = false
    
    
    init(id: Int,
         startX:Int, endX: Int,
         startY: Int,endY: Int,
         color: UIColor, chosen: Bool) {
        self.id = id
        self.startX = startX
        self.startY = startY
        self.endX = endX
        self.endY = endY
        self.color = color
        self.chosen = chosen
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(id, forKey: "id")
        coder.encode(chosen, forKey: "chosen")
        coder.encode(color, forKey: "color")
        coder.encode(startX, forKey: "startX")
        coder.encode(startY, forKey: "startY")
        coder.encode(endX, forKey: "endX")
        coder.encode(endY, forKey: "endY")
    }
    
    required init?(coder: NSCoder) {
        id = coder.decodeInteger(forKey: "id")
        chosen = coder.decodeBool(forKey: "chosen")
        startX = coder.decodeInteger(forKey: "startX")
        startY = coder.decodeInteger(forKey: "startY")
        endX = coder.decodeInteger(forKey: "endX")
        endY = coder.decodeInteger(forKey: "endY")
        color = coder.decodeObject(forKey: "color") as? UIColor ?? .black
    }
}

final class VectorAsData: ObservableObject {
    
    private enum VectorKeys: String {
        case userName
        case lastVector
    }
    
    static var lastVector: VectorModel! {
        get{
            guard let savedData = UserDefaults.standard.object(forKey: VectorKeys.lastVector.rawValue) as? Data,
                  let decodedModel = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedData) as? VectorModel else {
                return nil }
            return decodedModel
        }
        set{
            
            let defaults = UserDefaults.standard
            let key = VectorKeys.lastVector.rawValue
            
            if let lastVector = newValue {
                if let saveData = try? NSKeyedArchiver.archivedData(
                    withRootObject: lastVector,
                    requiringSecureCoding: false){
                    defaults.set(saveData, forKey: key)
//
                }
            }
        }
    }
    
    static var name: String! {
        get{
            return UserDefaults.standard.string(forKey: VectorKeys.userName.rawValue)
        }
        set {
            let defaults = UserDefaults.standard
            let key = VectorKeys.userName.rawValue
            if let name = newValue {
                defaults.set(name, forKey: key)
            }
        }
    }
}

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
