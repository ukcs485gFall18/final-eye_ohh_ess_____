//
//  EasyAI.swift
//  ARKitHorizontalPlaneDemo
//
//  Created by Karthik on 10/30/18.
//  Copyright © 2018 eye_Ohh_ess. All rights reserved.
//

import Foundation


class EasyAI {
    
    struct Location {
        var x, y, z: Int?
    }
    
    var availablePositions: [String] = []
    
    init() {
        for i in 0...2 {
            for j in 0...2 {
                for k in 0...2 {
                    availablePositions.append(String(i) + String(j) + String(k))
                }
            }
        }
    }
    
    func removeLocation(x: Int, y: Int, z:Int) {
        let idx = availablePositions.firstIndex(of: String(x) + String(y) + String(z))
        availablePositions.remove(at: idx!)
    }
    
    func getMove() -> Location {
        let moveStr = availablePositions.randomElement()
        var location = Location()
        
        var moveArr = Array(moveStr!)
        
        location.x = Int(String(moveArr[0]))
        location.y = Int(String(moveArr[1]))
        location.z = Int(String(moveArr[2]))
        return location
    }
}