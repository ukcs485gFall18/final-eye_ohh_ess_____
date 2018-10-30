//
//  RootViewModel.swift
//  ARKitHorizontalPlaneDemo
//
//  Created by Dagmawi Nadew-Assefa on 10/29/18.
//  Copyright © 2018 eye_Ohh_ess. All rights reserved.
//

import SceneKit


class RootViewModel {
    
    typealias DidPlaceShip = ((SCNNode) -> ())
    
    var notifyPlace: DidPlaceShip?
    var previousLocation = CGPoint(x: DefaultPoint.xLocation, y: DefaultPoint.yLocation)
    var shipPlaced: Bool = false
    
    
    
    func previewBox(at vector: Vector) {
        
        if !shipPlaced {
            let previewBox = SCNBox(width: PreviewBox.width, height: PreviewBox.height,
                             length: PreviewBox.length, chamferRadius: PreviewBox.radius)
            
            let boxNode = SCNNode()
            boxNode.geometry = previewBox
            boxNode.position = SCNVector3(vector.xCoordinate,
                                          vector.yCoordinate,
                                          vector.zCoordinate)
            notifyPlace?(boxNode)
        }
        
    }
}
