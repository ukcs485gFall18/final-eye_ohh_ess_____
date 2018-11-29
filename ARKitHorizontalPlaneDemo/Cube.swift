//
//  Cube.swift
//  ARKitHorizontalPlaneDemo
//
//  Created by Karthik on 10/28/18.
//  Copyright © 2018 eye_Ohh_ess. All rights reserved.
//

import Foundation
import UIKit
import ARKit


class Cube {
    
    var defaultCell = Cell(x: 0, y: 0, z: 0)
    var cube = [[[Cell]]]()
    

    init () {
        self.cube = [[[Cell]]](repeating:[[Cell]](repeating:[Cell](repeating:defaultCell, count:3), count:3), count:3)

        fillCubeArray()
    }
    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    public func actionPerformed() {
        // get touch location and determine cell to be modified
        
        // based on whos turn it is modify cell state (cross or sphere)
        
        // check game state checkWinner
    }
    
    public func fillCubeArray() {
        // fill cells in the cube 3D array array
//        for i in 0...2 {
//            for j in 0...2 {
//                for k in 0...2 {
//                    cube[i][j][k] = Cell(x: i, y: j, z: k)
//                }
//            }
//        }
    }
    
    public func fillCubeObject() {
        // fill cells in the cube 3D array array
    }
    
    public func previewCube() {
        // replace the cube with the outline 3D object
    }
    
    public func removeCube()   {  // NOTE: this function might now be needed.
        // remove cell object from the scene
    }
    
    public func setPreviewCubeSize()   {
        // update the preview Cube size as user resizes the cube
    }
    
    private func newCube() {
        // remove all cells
        
        fillCubeArray()
        
        // maybe reposition
    
    }

}
