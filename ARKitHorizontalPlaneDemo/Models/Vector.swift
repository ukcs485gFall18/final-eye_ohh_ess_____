//
//  Vector.swift
//  ARKitHorizontalPlaneDemo
//
//  Created by Dagmawi Nadew-Assefa on 10/30/18.
//  Copyright © 2018 eye_Ohh_ess. All rights reserved.
//

import Foundation
import simd

struct Vector {
    
    let xCoordinate: Float
    let yCoordinate: Float
    let zCoordinate: Float
    
    init(from translation: float3) {
        self.xCoordinate = translation.x
        self.yCoordinate = translation.y
        self.zCoordinate = translation.z
    }
}








