//
//  Node.swift
//  ARKitHorizontalPlaneDemo
//
//  Created by Dagmawi Nadew-Assefa on 10/30/18.
//  Copyright © 2018 eye_Ohh_ess. All rights reserved.
//

import ARKit


class Node: SCNNode {
    
    init(with anchor: ARPlaneAnchor) {
        super.init()
        self.geometry = Plane(anchor: anchor)
        updatePosition(for: anchor)
        setEuglersAngles()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func updatePosition(for anchor: ARPlaneAnchor) {
        
        self.position = SCNVector3(CGFloat(anchor.center.x),
                          CGFloat(anchor.center.y),
                          CGFloat(anchor.center.z))
        
    }
    
    private func setEuglersAngles() {
        self.eulerAngles.x = -.pi/2
    }
    
}
