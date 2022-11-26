//
//  drawTriangle.swift
//  vectors
//
//  Created by User on 21.11.22.
//

import Foundation
import SpriteKit

struct VectorShape {
    var line:SKShapeNode
    var triangle: SKShapeNode
}

func drawVector(_ vector: Memory.Vector) -> VectorShape {
    let line = SKShapeNode()
    let pathToLine = CGMutablePath()
    
    pathToLine.move(to: vector.start)
    pathToLine.addLine(to: vector.end)

    line.path = pathToLine
    line.strokeColor = vector.chosen ? .red : vector.color
    line.lineWidth = vector.chosen ? 10 : 3
    line.zPosition = 5
    
    let triangle = getTriangle(from: vector.start, to: vector.end, color: vector.chosen ? .red : vector.color)

    return VectorShape(line: line, triangle: triangle)
}

func subtractFromVector(p1:CGPoint, p2:CGPoint,minLenght: CGFloat) -> CGPoint {
    let maxLength = sqrt(pow((p2.x - p1.x), 2) + pow((p2.y - p1.y), 2))
    let precent = minLenght / maxLength
    

    var vectorEndPointWithoutTriangleWidth = CGPoint(
        x:  ((1 - precent) * p2.x ) + p1.x * precent,
        y:  ((1 - precent) * p2.y ) + p1.y * precent
    )
    
    return vectorEndPointWithoutTriangleWidth
                
}

func getTriangle(from start:CGPoint, to end:CGPoint, color: UIColor) -> SKShapeNode {
    let triangleWidth: CGFloat = 10
    let triangleHeight: CGFloat = 30
    
    
    let vectorEndPointWithoutTriangleWidth = subtractFromVector(p1: start, p2: end, minLenght: triangleWidth)
    
    let triangleStartPoint = vectorEndPointWithoutTriangleWidth
    
    let triangleLeftPoint = CGPoint(
        x: triangleStartPoint.x - triangleHeight,
        y: triangleStartPoint.y - triangleWidth
    )
    let triangleMiddlePoint = CGPoint(
        x: triangleStartPoint.x - triangleHeight / 2,
        y: triangleStartPoint.y
    )
    let triangleRightPoint = CGPoint(
        x: triangleStartPoint.x - triangleHeight,
        y: triangleStartPoint.y + triangleWidth
    )
    
    let trianglePath = CGMutablePath();
        trianglePath.move(to: triangleStartPoint)
        trianglePath.addLine(to: triangleLeftPoint)
        trianglePath.addLine(to: triangleMiddlePoint)
        trianglePath.addLine(to: triangleRightPoint)
        trianglePath.addLine(to: triangleStartPoint)

    let triangle = SKShapeNode(path: trianglePath, centered: true)

    triangle.position = vectorEndPointWithoutTriangleWidth
    triangle.strokeColor = color
    triangle.lineWidth = 3
    triangle.fillColor = color
    triangle.zPosition = 2
    
    let triangleAngle = atan2(end.y - start.y, end.x - start.x)
    triangle.zRotation = triangleAngle
    
    return triangle
}
