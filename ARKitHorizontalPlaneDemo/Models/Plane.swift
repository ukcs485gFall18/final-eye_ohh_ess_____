//
//  Plane.swift
//  ARKitHorizontalPlaneDemo
//
//  Created by Dagmawi Nadew-Assefa on 10/30/18.
//  Copyright © 2018 eye_Ohh_ess. All rights reserved.
//

import ARKit


class Plane: SCNPlane {
    
    init(anchor: ARPlaneAnchor) {
        super.init()
        updateDimension(with: anchor)
        
        // MARK:- Give the plane a background color.
        self.materials.first?.diffuse.contents = UIColor.transparentLightBlue
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func updateDimension(with anchor: ARPlaneAnchor) {
        self.width = CGFloat(anchor.extent.x)
        self.height = CGFloat(anchor.extent.z)
    }
    
}
