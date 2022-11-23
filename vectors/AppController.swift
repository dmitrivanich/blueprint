import Foundation
import SwiftUI
import SpriteKit

class VectorsGame: ObservableObject{
    

    static let vectors: [Memory.Vector] = [
        Memory.Vector(id: 0, start: CGPoint(x: 0, y: 0), end: CGPoint(x:0, y:300), color: UIColor.black),
        Memory.Vector(id: 1, start: CGPoint(x: 0, y: 0), end: CGPoint(x:300, y:0), color: UIColor.black)
    ]

    static func createMemoryGame() -> Memory {
        Memory(
            vectors: vectors,
            pixelsForOneGridCell: 50,
            isVectorCreating: false
        )
    }
    
    @Published private(set) var model: Memory = createMemoryGame()

    
    var vectors: [Memory.Vector] {
        return model.vectors
    }
    
    var pixelsForOneGridCell: CGFloat {
        return model.pixelsForOneGridCell
    }
    
    var isVectorCreating: Bool {
        return model.isVectorCreating
    }
    
    
    
    // MARK: - Intent(s)
    
    func choose(_ vector: Memory.Vector){
        model.choose(vector)
    }
    
    func addVector(_ vector: Memory.Vector){
        model.add(vector)
    }
    
    func changeVectorCreatingStatus(){
        model.changeVectorCreatingStatus()
    }
}
