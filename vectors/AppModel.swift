import Foundation
import SwiftUI

struct Memory{//Memory of Vectors game
    
    private(set) var vectors: Array<Vector> = []
    private(set) var pixelsForOneGridCell: CGFloat = 50
    private(set) var isVectorCreating: Bool = false
    
    init(
        vectors: Array<Vector>,
        pixelsForOneGridCell: CGFloat,
        isVectorCreating: Bool
    ) {
        self.vectors = vectors
        self.pixelsForOneGridCell = pixelsForOneGridCell
        self.isVectorCreating = isVectorCreating
    }
    
    public func getAllVectors() -> Array<Vector> {
        print(vectors)
        return vectors
    }
    
    mutating func add(_ vector: Vector) {
        vectors.append(vector)
    }
    
    mutating func choose(_ vector: Vector) {
        let choosenIndex = index(of: vector)
        vectors[choosenIndex].chosen = true
    }
    mutating func unChoose(_ vector: Vector) {
        let choosenIndex = index(of: vector)
        vectors[choosenIndex].chosen = false
    }
    
    mutating func changeVectorCreatingStatus() {
        isVectorCreating.toggle()
    }
    
    mutating func move(_ vector: Vector,_ start: CGPoint,_ end: CGPoint) {
        let choosenIndex = index(of: vector)
        vectors[choosenIndex].start = start
        vectors[choosenIndex].end = end
    }
    
    func index(of vector: Vector) -> Int {
        for index in 0..<vectors.count {
            if vectors[index].id == vector.id {
                return index
            }
        }
        return 0
    }
 
    struct Vector: Identifiable {
        var id: Int
        var start: CGPoint = .zero
        var end: CGPoint = .zero
        var color: UIColor = UIColor(.black)
        var chosen: Bool = false
    }
}
