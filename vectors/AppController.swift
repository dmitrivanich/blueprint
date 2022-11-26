import Foundation
import SwiftUI
import SpriteKit

class VectorsGame: ObservableObject{
    
    static let n: CGFloat = 50
    static let vectors: [Memory.Vector] = [
        Memory.Vector(id: 0, start: CGPoint(x: 0 - n, y: 0), end: CGPoint(x:0 - n, y:300), color: UIColor.black),
        Memory.Vector(id: 1, start: CGPoint(x: 0 - n, y: 300), end: CGPoint(x:300 - n, y:300), color: UIColor.black),
        Memory.Vector(id: 2, start: CGPoint(x: 300 - n, y: 300), end: CGPoint(x:300 - n, y:0), color: UIColor.black),
        Memory.Vector(id: 3, start: CGPoint(x: 300 - n, y: 0), end: CGPoint(x:0 - n, y:0), color: UIColor.black),
        
        Memory.Vector(id: 4, start: CGPoint(x: -150 - n, y: -150), end: CGPoint(x:-150 - n, y:150), color: UIColor.black),
        Memory.Vector(id: 5, start: CGPoint(x: -150 - n, y: 150), end: CGPoint(x:150 - n, y:150), color: UIColor.black),
        Memory.Vector(id: 6, start: CGPoint(x: 150 - n, y: 150), end: CGPoint(x:150 - n, y:-150), color: UIColor.black),
        Memory.Vector(id: 7, start: CGPoint(x: 150 - n, y: -150), end: CGPoint(x:-150 - n, y:-150), color: UIColor.black),
        
        Memory.Vector(id: 8, start: CGPoint(x: -150 - n, y: -150), end: CGPoint(x:0 - n, y:0), color: UIColor.black),
        Memory.Vector(id: 9, start: CGPoint(x: -150 - n, y: 150), end: CGPoint(x:0 - n, y:300), color: UIColor.black),
        Memory.Vector(id: 10, start: CGPoint(x: 150 - n, y: 150), end: CGPoint(x:300 - n, y:300), color: UIColor.black),
        Memory.Vector(id: 11, start: CGPoint(x: 150 - n, y: -150), end: CGPoint(x:300 - n, y:0), color: UIColor.black),
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
    func unChoose(_ vector: Memory.Vector){
        model.unChoose(vector)
    }
    
    func addVector(_ vector: Memory.Vector){
        model.add(vector)
    }
    
    func changeVectorCreatingStatus(){
        model.changeVectorCreatingStatus()
    }
    
    func moveVector(_ vector: Memory.Vector,to start: CGPoint,_ end:CGPoint){
        model.move(vector, start, end)
    }
}
