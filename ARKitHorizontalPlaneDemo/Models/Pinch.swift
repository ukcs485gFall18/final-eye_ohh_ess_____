//
//  Pinch.swift
//  ARKitHorizontalPlaneDemo
//
//  Created by Dagmawi Nadew-Assefa on 10/30/18.
//  Copyright © 2018 eye_Ohh_ess. All rights reserved.
//

import SceneKit

struct Pinch {
    
    let xScale: Float
    let yScale: Float
    let zScale: Float
    
    init(from gesture: UIPinchGestureRecognizer) {
        self.xScale = Float(gesture.scale)
        self.yScale = Float(gesture.scale)
        self.zScale = Float(gesture.scale)
    }
    
}
