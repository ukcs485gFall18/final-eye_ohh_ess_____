//
//  ShipNode.swift
//  ARKitHorizontalPlaneDemo
//
//  Created by Dagmawi Nadew-Assefa on 10/30/18.
//  Copyright © 2018 eye_Ohh_ess. All rights reserved.
//

import SceneKit


class ShipNode: SCNNode {
    
    private var isPlaced = false
    
    init(named: String) {
        super.init()
        self.name = named
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setPosition(at point: float3) {
        self.position = SCNVector3(x: point.x, y: point.y, z: point.z)
        self.isPlaced = true
    }
    
    func remove() {
        self.isPlaced = false
        self.removeFromParentNode()
    }
    
    func rotate(with value: Float) {
        if isPlaced {
            self.eulerAngles.y = value
        }
    }
    
    func scale(with pinch: Pinch) {

        self.scale = SCNVector3Make(pinch.xScale * scale.x,
                                    pinch.yScale * scale.y,
                                    pinch.zScale * scale.z)
    
    }
    
}
