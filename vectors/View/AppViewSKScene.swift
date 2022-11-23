//
//  SceneView.swift
//  vectors
//
//  Created by User on 20.11.22.
//

import SwiftUI
import SpriteKit
import Foundation

class VectorsScene: SKScene {
    @Binding var currentStatus: GameStatus
    var viewModel: VectorsGame? = VectorsGame()
    var gridScale: CGFloat = 50
    
    let vectorLine = SKShapeNode()
    let vectorCircle = SKShapeNode(circleOfRadius: 15)
    let xLine = SKSpriteNode(color: UIColor(.white), size: .zero)
    let yLine = SKSpriteNode(color: UIColor(.white), size: .zero)
    let xyCenter = SKShapeNode(circleOfRadius: 10)
    
    var cameraNode = SKCameraNode()
    let cameraCenter = SKShapeNode(circleOfRadius: 5)
    let centerToCameraLine = SKShapeNode()
    
    var startOfVector: CGPoint = .zero
    var endOfVector: CGPoint = .zero
    
    
    init(_ status: Binding<GameStatus>) {
        _currentStatus = status
        super.init(size: CGSize(
            width: UIScreen.main.bounds.width * 1.5,
            height: UIScreen.main.bounds.height * 1.5))
        self.scaleMode = .fill
    }
    
    required init?(coder aDecoder: NSCoder) {
        _currentStatus = .constant(.enableCamera)
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches{
            
            let touchLocation = touch.location(in: self)
            
            if(!currentStatus.isVectorCreating) {
                
            } else {
                vectorCircle.position = touchLocation
                vectorCircle.alpha = 1
                
                startOfVector = CGPoint(
                    x: round(touchLocation.x / gridScale) * gridScale,
                    y: round(touchLocation.y / gridScale) * gridScale
                )
            }
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches{
            
            let touchLocation = touch.location(in: self)
            
            if(!currentStatus.isVectorCreating) {
                let previousLocation = touch.previousLocation(in: self)
                
                camera?.position.x -= touchLocation.x - previousLocation.x
                camera?.position.y -= touchLocation.y - previousLocation.y
                
                cameraCenter.position = camera?.position ?? .zero
                redrawCenterLine()
            } else {
                endOfVector = CGPoint(
                    x: round(touchLocation.x / gridScale) * gridScale,
                    y: round(touchLocation.y / gridScale) * gridScale
                )
                redrawVectorLine()
            }
        }
        
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches{
            
            let touchLocation = touch.location(in: self)
            
            if(!currentStatus.isVectorCreating) {
                //                xLine.position.x = touchLocation.x + distanceToLine.x
                //                yLine.position.y = touchLocation.y + distanceToLine.y
                
                //                camera?.position = touchLocation
            } else {
                
                let newVector = Memory.Vector(
                    id: viewModel!.vectors.count + 1,
                    start: startOfVector,
                    end: endOfVector,
                    color: UIColor.random
                )
                
                vectorCircle.alpha = 0
                viewModel!.addVector(newVector)
                updateVectors()
//                currentStatus.isVectorCreating = false
//                viewModel!.changeVectorCreatingStatus()
            }
        }
        
    }
    
    

}

//MARK: - didMove
extension VectorsScene {
    override func didMove(to view: SKView) {
        let screenSize: CGSize = self.size
        backgroundColor = UIColor(red: 0.08, green: 0.3, blue: 0.6, alpha: 1)
        
        let roundedCenter = CGSize(width: 0, height: 0)
        
        yLine.anchorPoint = CGPoint.zero
        yLine.position = CGPoint(x: roundedCenter.width, y: -50000)
        yLine.size = CGSize(width: 3, height: 100000)
        yLine.zPosition = 2
        
        xLine.anchorPoint = CGPoint.zero
        xLine.position = CGPoint(x: -50000, y: roundedCenter.height)
        xLine.size = CGSize(width: 100000, height: 3)
        xLine.zPosition = 2
        
        xyCenter.position = CGPoint(
            x: roundedCenter.width,
            y: roundedCenter.height)
        xyCenter.fillColor = .white
        
        vectorLine.strokeColor = .black
        vectorLine.lineWidth = 3
        vectorLine.zPosition = 4
        
        vectorCircle.strokeColor = .black
        vectorCircle.zPosition = 4
        vectorCircle.alpha = 0
        vectorCircle.fillColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        cameraCenter.strokeColor = .black
        cameraCenter.zPosition = 4
        cameraCenter.fillColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        cameraCenter.alpha = 0
        
        centerToCameraLine.strokeColor = .black
        centerToCameraLine.lineWidth = 3
        centerToCameraLine.zPosition = 4
        centerToCameraLine.alpha = 0
        
        
        for rangeGrid in Int(-50000)...Int(50000) {
            
            
            if(rangeGrid % Int(gridScale) == 0) {
                
                var lineWidth: CGFloat = 0
                var alpha: CGFloat = 0
                
                if(rangeGrid % Int(gridScale) == 0){
                    lineWidth = 3
                    alpha = 0.4
                    if(rangeGrid % Int(gridScale * 5) == 0){
                        lineWidth = 4
                        alpha = 0.5
                        if(rangeGrid % Int(gridScale * 10) == 0){
                            lineWidth = 5
                            alpha = 0.6
                        }
                    }
                    
                }
                
                addGridLine(
                    from: CGPoint(x: Double(rangeGrid), y: -50000),
                    to: CGPoint(x: Double(rangeGrid), y: 50000),
                    lineWidth: lineWidth,
                    alpha: alpha
                )
                addGridLine(
                    from: CGPoint(x: -50000, y: Double(rangeGrid)),
                    to: CGPoint(x: 50000, y: Double(rangeGrid)),
                    lineWidth: lineWidth,
                    alpha: alpha
                )
                
            }
        }
        
        addChild(xLine)
        addChild(yLine)
        addChild(vectorLine)
        addChild(vectorCircle)
        addChild(xyCenter)
        addChild(cameraCenter)
        addChild(centerToCameraLine)
        
        updateVectors()
        
        addChild(cameraNode)
        camera = cameraNode
        camera?.position = CGPoint.zero
    }
}

//MARK: - update vectors
extension VectorsScene{
    private func updateVectors() {
        for vector in viewModel!.vectors{
            let vectorShape: VectorShape = drawVector(vector)
            addChild(vectorShape.line)
            addChild(vectorShape.triangle)
            
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
        let newVector : SKShapeNode = vectorLine
        
        let pathForVector = CGMutablePath()
        pathForVector.move(to: startOfVector)
        pathForVector.addLine(to: endOfVector)
        newVector.path = pathForVector
        
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

        centerToCameraLine.alpha = lengthToStart / 10000
        cameraCenter.alpha = 0.9

    }

}
