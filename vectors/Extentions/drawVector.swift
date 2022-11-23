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
    line.strokeColor = vector.color
    line.lineWidth = 3
    line.zPosition = 2
    
    let triangle = getTriangle(from: vector.start, to: vector.end, color: vector.color)

    return VectorShape(line: line, triangle: triangle)
}

func getTriangle(from start:CGPoint, to end:CGPoint, color: UIColor) -> SKShapeNode {
    let triangleWidth: CGFloat = 10
    let triangleHeight: CGFloat = 30
    
    let triangleStartPoint = CGPoint(
        x: start.x,
        y: end.y
    )
    
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

    triangle.position = end
    triangle.strokeColor = color
    triangle.lineWidth = 3
    triangle.fillColor = color
    triangle.zPosition = 2
    
    let triangleAngle = atan2(end.y - start.y, end.x - start.x)
    triangle.zRotation = triangleAngle
    
    return triangle
}
