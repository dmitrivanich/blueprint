//
//  SceneView.swift
//  vectors
//
//  Created by User on 20.11.22.
//

import SwiftUI
import SpriteKit
import CoreData

class VectorsScene: SKScene, UIGestureRecognizerDelegate {
    @Environment (\.managedObjectContext) var moc
    
    @Binding var currentStatus: GameStatus
    
    var touchLocation: CGPoint = .zero
    var viewModel: VectorsGame? = VectorsGame()
    var gridCellSize: CGFloat = 50

    var chosenVector: Memory.Vector = Memory.Vector(id: -1, start: .zero, end: .zero, color: .black)
    var isLongPress: Bool = false
    
    let vectorLine = SKShapeNode()
    var vectorCircle = SKShapeNode(circleOfRadius: 15)
    
    let xLine = SKSpriteNode(color: UIColor(.white), size: .zero)
    let yLine = SKSpriteNode(color: UIColor(.white), size: .zero)
    let xyCenter = SKShapeNode(circleOfRadius: 10)
    
    var cameraNode = SKCameraNode()
    let cameraCenter = SKShapeNode(circleOfRadius: 5)
    let staticCameraCenter = SKShapeNode(circleOfRadius: 5)
    let centerToCameraLine = SKShapeNode()
    
    var startOfVector: CGPoint = .zero
    var endOfVector: CGPoint = .zero
    var triangleOfVector = SKShapeNode()
    
    var currentVectorLineShapeArray = [SKShapeNode()]
    var currentVectorTriangleShapeArray = [SKShapeNode()]
    
    init(_ status: Binding<GameStatus>) {
        _currentStatus = status
        super.init(size: CGSize(
            width: UIScreen.main.bounds.width * 2,
            height: UIScreen.main.bounds.height * 2))
        self.scaleMode = .fill
    }
    
    required init?(coder aDecoder: NSCoder) {
        _currentStatus = .constant(.enableCamera)
        super.init(coder: aDecoder)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        let halfGridCellSize = gridCellSize / 2
        let speed = 0.5
        
        if((camera!.position.x < halfGridCellSize) && (camera!.position.x > -halfGridCellSize) &&
           (camera!.position.y < halfGridCellSize) && (camera!.position.y > -halfGridCellSize)) {
            
            leadCameraToCenter(speed: speed)

        }
    }
    
    @objc func longPress(sender: UILongPressGestureRecognizer) {
        
         if sender.state == .began {
             isLongPress = true
             
             if(!currentStatus.isVectorCreating){
                 vectorLine.alpha = 1
                 findAndSelectVector(near: touchLocation)
                 moveVector()
                 redrawCenterLine()
                 redrawVectorLine()
             }
         }
         if sender.state == .ended { print("LongPress ENDED detected")
             isLongPress = false
             vectorLine.alpha = 1
             
             if(currentStatus.isVectorCreating){
                 createNewVector()
             }
         }
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            
            touchLocation = touch.location(in: self)
            
            if(!currentStatus.isVectorCreating) {
               
                
               
            } else {
                
                vectorCircle.position = touchLocation
                vectorCircle.alpha = 1
                vectorLine.alpha = 1
                
                startOfVector = CGPoint(
                    x: round(touchLocation.x / gridCellSize) * gridCellSize,
                    y: round(touchLocation.y / gridCellSize) * gridCellSize
                )
            }
        }
    }
    
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches{
            
            touchLocation = touch.location(in: self)
            
            if(!currentStatus.isVectorCreating) {
                let previousLocation = touch.previousLocation(in: self)
                
                camera?.position.x -= touchLocation.x - previousLocation.x
                camera?.position.y -= touchLocation.y - previousLocation.y
                
                cameraCenter.position = camera?.position ?? .zero
                
                moveVector()
                
                redrawCenterLine()
                redrawVectorLine()
            } else {
                endOfVector = CGPoint(
                    x: round(touchLocation.x / gridCellSize) * gridCellSize,
                    y: round(touchLocation.y / gridCellSize) * gridCellSize
                )
                redrawVectorLine()
            }
        }
        
    }

    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches{
            
            touchLocation = touch.location(in: self)
            
            if(!currentStatus.isVectorCreating) {
                
                if(chosenVector.id != -1) {
                    viewModel?.moveVector(chosenVector, to: startOfVector, endOfVector)
                    unselectVectors()
                    updateVectors()
                }
                
            } else {
                
                createNewVector()

            }
        }
        
    }
    
    

}

//MARK: - didMove
extension VectorsScene {
    override func didMove(to view: SKView) {
        let screenSize: CGSize = self.size
//        backgroundColor = UIColor(red: 0.08, green: 0.3, blue: 0.6, alpha: 1)
        backgroundColor = UIColor(red: 0.08, green: 0.34, blue: 0.88, alpha: 1)
        
        let pressed:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(sender:)))
        pressed.delegate = self
        pressed.minimumPressDuration = 0.1
        view.addGestureRecognizer(pressed)
        
        let roundedCenter = CGSize(width: 0, height: 0)
        
        yLine.anchorPoint = CGPoint.zero
        yLine.position = CGPoint(x: roundedCenter.width, y: -500000)
        yLine.size = CGSize(width: 3, height: 1000000)
        yLine.zPosition = 2
        
        xLine.anchorPoint = CGPoint.zero
        xLine.position = CGPoint(x: -500000, y: roundedCenter.height)
        xLine.size = CGSize(width: 1000000, height: 3)
        xLine.zPosition = 2
        
        xyCenter.position = CGPoint(
            x: roundedCenter.width,
            y: roundedCenter.height)
        xyCenter.fillColor = .white
        
        vectorLine.strokeColor = .red
        vectorLine.lineWidth = 10
        vectorLine.zPosition = 4
        
        vectorCircle.strokeColor = .black
        vectorCircle.zPosition = 4
        vectorCircle.alpha = 0
        vectorCircle.fillColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        cameraCenter.strokeColor = .black
        cameraCenter.zPosition = 4
        cameraCenter.fillColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        
        staticCameraCenter.strokeColor = .black
        staticCameraCenter.zPosition = 4
        staticCameraCenter.fillColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        
        centerToCameraLine.strokeColor = .black
        centerToCameraLine.lineWidth = 3
        centerToCameraLine.zPosition = 4
        centerToCameraLine.alpha = 0
        
        
        
        for rangeGrid in Int(-500000)...Int(500000) {
            
            
            if(rangeGrid % Int(gridCellSize) == 0) {
                
                var lineWidth: CGFloat = 0
                var alpha: CGFloat = 0
                
                if(rangeGrid % Int(gridCellSize) == 0){
                    lineWidth = 3
                    alpha = 0.4
                    if(rangeGrid % Int(gridCellSize * 5) == 0){
                        lineWidth = 4
                        alpha = 0.5
                        if(rangeGrid % Int(gridCellSize * 10) == 0){
                            lineWidth = 5
                            alpha = 0.6
                        }
                    }
                    
                }
                
                addGridLine(
                    from: CGPoint(x: Double(rangeGrid), y: -500000),
                    to: CGPoint(x: Double(rangeGrid), y: 500000),
                    lineWidth: lineWidth,
                    alpha: alpha
                )
                addGridLine(
                    from: CGPoint(x: -500000, y: Double(rangeGrid)),
                    to: CGPoint(x: 500000, y: Double(rangeGrid)),
                    lineWidth: lineWidth,
                    alpha: alpha
                )
                
            }
        }
        
        updateVectors()
        
        addChild(xLine)
        addChild(yLine)
        addChild(vectorLine)
        addChild(vectorCircle)
        addChild(xyCenter)
        addChild(cameraCenter)
        addChild(staticCameraCenter)
        addChild(centerToCameraLine)
        addChild(triangleOfVector)
        
        addChild(cameraNode)
        camera = cameraNode
        camera?.position = CGPoint.zero
    }
}

//MARK: - find vector near touch location
extension VectorsScene {
    private func findVector(of vectors: [Memory.Vector],near location: CGPoint) -> Memory.Vector? {
       
        var findedVectors: [FindedVector] = []
        
        for vector in vectors {
            var underVectorX = CGFloat(0)...CGFloat(1)
            var underVectorY = CGFloat(0)...CGFloat(1)

            if(vector.start.x <= vector.end.x) {
                underVectorX = vector.start.x - gridCellSize...vector.end.x + gridCellSize
            }

            if(vector.start.x >= vector.end.x) {
                underVectorX = vector.end.x - gridCellSize...vector.start.x + gridCellSize
            }

            if(vector.start.y <= vector.end.y) {
                underVectorY = vector.start.y - gridCellSize...vector.end.y + gridCellSize
            }

            if(vector.start.y >= vector.end.y) {
                underVectorY = vector.end.y - gridCellSize...vector.start.y + gridCellSize
            }

            if( underVectorX.contains(location.x) &&
                underVectorY.contains(location.y)
            ) {
                let length = getLength(from: location, to: vector.start, vector.end)
                findedVectors.append(FindedVector(vector: vector, length: length))
            }
            
        }
        
        if(findedVectors.count < 1) {
            return nil
        }
        
        var nearedVector = findedVectors[0]
        
        for vector in findedVectors {
            if(vector.length < nearedVector.length) {
                nearedVector = vector
            }
        }
        
        struct FindedVector {
            let vector: Memory.Vector
            let length: CGFloat
        }
        
        func getLength(from p1:CGPoint,to p2:CGPoint,_ p3:CGPoint) -> CGFloat {
            let length1 = sqrt(pow((p2.x - p1.x), 2) + pow((p2.y - p1.y), 2))
            let length2 = sqrt(pow((p3.x - p1.x), 2) + pow((p3.y - p1.y), 2))
            let length = length1 + length2
            print(length)
            return length
                        
        }
        
        return nearedVector.vector
    }
}
//MARK: - update vectors
extension VectorsScene{
    private func updateVectors() {
        
        if((currentVectorLineShapeArray.count) != 0) {
            removeChildren(in: currentVectorLineShapeArray)
            currentVectorLineShapeArray.removeAll()
        }
        if((currentVectorTriangleShapeArray.count) != 0) {
            removeChildren(in: currentVectorTriangleShapeArray)
            currentVectorTriangleShapeArray.removeAll()
        }
        
        for vector in viewModel!.vectors{
            let vectorShape: VectorShape = drawVector(vector)
           
            currentVectorTriangleShapeArray.append(vectorShape.triangle)
            currentVectorLineShapeArray.append(vectorShape.line)
        }
        
        for shape in currentVectorLineShapeArray {
            addChild(shape)
        }
        for shape in currentVectorTriangleShapeArray {
            addChild(shape)
        }
    }
}

//MARK: - add Grid line
extension VectorsScene {
    private func addGridLine(from start: CGPoint,to end: CGPoint, lineWidth: CGFloat, alpha: CGFloat) {
        let line = SKShapeNode()
        let pathToDraw = CGMutablePath()
        
        pathToDraw.move(to: start)
        pathToDraw.addLine(to: end)
        
        line.path = pathToDraw
        line.strokeColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        line.alpha = alpha
        line.lineWidth = lineWidth
        line.zPosition = 2
        
        
        addChild(line)
    }
}




//MARK: - Redraw vector line

extension VectorsScene {
    private func redrawVectorLine() {
        
        let pathForVector = CGMutablePath()
        pathForVector.move(to: startOfVector)
        pathForVector.addLine(to: endOfVector)
        vectorLine.path = pathForVector
        vectorLine.fillColor = UIColor(.red)
        
        vectorCircle.position = endOfVector

    }
}


//MARK: - Redraw center function

extension VectorsScene {
    private func redrawCenterLine() {
        let centerToCameraLineNode : SKShapeNode = centerToCameraLine

        let P1 = xyCenter.position
        let P2 = cameraCenter.position

        let pathForCamera = CGMutablePath()
        pathForCamera .move(to: P1)
        pathForCamera .addLine(to: P2)
        centerToCameraLineNode.path = pathForCamera

        let lengthToStart = sqrt(pow((P2.x - P1.x), 2) + pow((P2.y - P1.y), 2))

        cameraNode.xScale = 1 + lengthToStart / 2500
        cameraNode.yScale = 1 + lengthToStart / 2500

        centerToCameraLine.alpha = lengthToStart / 1000
        centerToCameraLine.lineWidth = 1 + lengthToStart / 1000
        cameraCenter.alpha = 0.9

    }

}

//MARK: - lead the camera to center

extension VectorsScene {
    func leadCameraToCenter(speed: Double){
        if(camera!.position.x > 0) {
            camera!.position.x -= speed
        }
        if(camera!.position.y > 0) {
            camera!.position.y -= speed
        }
        if(camera!.position.x < 0) {
            camera!.position.x += speed
        }
        if(camera!.position.y < 0) {
            camera!.position.y += speed
        }
        cameraCenter.position = camera?.position ?? .zero
    }
}
//MARK: - create new vector

extension VectorsScene {
    func createNewVector(){
        let newVector = Memory.Vector(
            id: viewModel!.vectors.count + 1,
            start: startOfVector,
            end: endOfVector,
            color: UIColor.random
        )
        
        vectorCircle.alpha = 0
        vectorLine.alpha = 0
        viewModel!.addVector(newVector)
        updateVectors()
    }
}

//MARK: - unselect vectors

extension VectorsScene {
    func unselectVectors(){
        
        for vector in viewModel!.vectors {
            viewModel!.unChoose(vector)
        }
        
        self.chosenVector = Memory.Vector(id: -1, start: .zero, end: .zero, color: .black)
        updateVectors()
        
    }
}

//MARK: - select vector

extension VectorsScene {
    func findAndSelectVector(near here:CGPoint){
        
        print("checking...")
        let chosenVector: Memory.Vector = findVector(of: viewModel!.vectors, near: here) ?? Memory.Vector(id: -1, start: .zero, end: .zero, color: .black)
        
        if(chosenVector.id >= 0) {
            print(chosenVector.id)
            
            viewModel!.choose(chosenVector)
            self.chosenVector = chosenVector
            updateVectors()
        }else{
            print("not found")
        }
        
    }
}
//MARK: - move vector

extension VectorsScene {
    func moveVector(){

        for vector in viewModel!.vectors {
            let rangeStartX = (-gridCellSize / 2 + vector.start.x)...gridCellSize / 2 + vector.start.x
            let rangeStartY = (-gridCellSize / 2 + vector.start.y)...gridCellSize / 2 + vector.start.y
            let rangeEndX = (-gridCellSize / 2 + vector.end.x)...gridCellSize / 2 + vector.end.x
            let rangeEndY = (-gridCellSize / 2 + vector.end.y)...gridCellSize / 2 + vector.end.y

            if(rangeStartX.contains(cameraCenter.position.x) && rangeStartY.contains(cameraCenter.position.y)){
                cameraCenter.position = CGPoint(x: vector.start.x, y: vector.start.y)
            }
            if(rangeEndX.contains(cameraCenter.position.x) && rangeEndY.contains(cameraCenter.position.y)){
                cameraCenter.position = CGPoint(x: vector.end.x, y: vector.end.y)
            }
            
            
            
        }
        
        startOfVector = cameraCenter.position
        
        endOfVector = CGPoint(
            x: startOfVector.x - chosenVector.start.x + chosenVector.end.x,
            y: startOfVector.y - chosenVector.start.y + chosenVector.end.y
        )
        
       
        
    }
}

