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
        var i, j, k: Int      // stores the location of the cell
    }
    
    var cellNode: SCNNode!
    var index = Index(i: -1, j: -1, k: -1)
    var cellName: String!
    var state: cellState?  // is reset for generator and solver
    
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
    
    func setPosition(pos: SCNVector3) {
        self.cellNode.position = pos
    }
    
    func removeXO(cubeIndex: String, type: String) {
        // removes the 'X' or 'O' 3D object so it is a empty cell
    }
}
