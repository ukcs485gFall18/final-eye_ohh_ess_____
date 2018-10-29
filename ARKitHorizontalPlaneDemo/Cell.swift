//
//  cell.swift
//  ARKitHorizontalPlaneDemo
//
//  Created by Karthik on 10/28/18.
//  Copyright © 2018 eye_Ohh_ess. All rights reserved.
//

import Foundation

public class Cell {
    
    enum cellState {
        case sphere
        case cross
        case empty
    }
    
    public var x, y, z: Int?      // stores the location of the cell
    
    public var state: cellState?  // is reset for generator and solver
    
    // touch/tap event listener
    // linkage to actual 3D objects
    
    init(x: Int, y: Int, z:Int) {
        self.x = x
        self.y = y
        self.z = z
        self.state = cellState.cross
        // create empty cell 3D object
        
        // set cell location in space relative to 0,1,0
        
        // set preferred size

    }
    
    public func fillX() {
        // replace the cell with the X 3D object
    }
    
    public func prevX() {
        // replace the cell with the X 3D object
    }
    
    public func fillO() {
        // replace the cell with the preview O 3D object
    }
    
    public func prevO() {
        // replace the cell with the preview X 3D object
    }
    
    public func removeXO()   {
        // remove object from the the cell
    }

    public func removeCell()   {  // NOTE: this function might now be needed.
        // remove cell object from the scene
    }
    
    public func rePlaceCell()   {
        // re position x, y, z placement during resize
    }
}
