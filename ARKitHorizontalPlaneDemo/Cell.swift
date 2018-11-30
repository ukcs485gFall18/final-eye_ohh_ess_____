//
//  cell.swift
//  ARKitHorizontalPlaneDemo
//
//  Created by Karthik on 10/28/18.
//  Copyright © 2018 eye_Ohh_ess. All rights reserved.
//

import Foundation
import UIKit
import ARKit

class Cell {
    
    enum cellState {
        case sphere
        case cross
        case empty
    }
    
    struct Index {
        var i, j, k: Int?      // stores the location of the cell
    }
    
    var cellNode: SCNNode!
    var index = Index()
    var cellName: String!
    var state: cellState?  // is reset for generator and solver
    
    // touch/tap event listener
    // linkage to actual 3D objects
    init(i: Int, j: Int, k:Int, state: cellState) {
        
        // set cell index
        self.index.i = i
        self.index.j = j
        self.index.k = k
        self.cellName = String(i) + String(j) + String(k)
        
        self.setCellState(state: state)
        
        //        set preferred size
        //        super.init()
    }
    
    func setCellState(state: cellState) {
        var name: String!
        if (state == cellState.empty) {
            name = "Cell-Empty"
        }
        else if (state == cellState.cross) {
            name = "Cell-Cross"
        }
        else if (state == cellState.sphere){
            name = "Cell-Sphere"
        }
        else { fatalError() }
        
        self.state = state          // set stare to empty, cross or sphere
        
        guard let gameScene = SCNScene(named: "art.scnassets/game.scn") else { fatalError() }
        guard let node = gameScene.rootNode.childNode(withName: name, recursively: false)
            else { fatalError() }
        
        
        self.cellNode = node
        self.cellNode.name = cellName
    }
    

    
//    func setPosition(xval: Float, yval: Float, zval: Float) {
//        self.cellNode.position = SCNVector3(x: xval, y: yval, z: zval)
//    }
//
    func setPosition(pos: SCNVector3) {
        self.cellNode.position = pos
    }
    
    func removeXO(cubeIndex: String, type: String) {
        // removes the 'X' or 'O' 3D object so it is a empty cell
        
    }
    
    func removeXO()   {
        // remove object from the the cell
    }
    
    func removeCell()   {  // NOTE: this function might now be needed.
        // remove cell object from the scene
    }
    
    func rePlaceCell()   {
        // re position x, y, z placement during resize
    }
}
