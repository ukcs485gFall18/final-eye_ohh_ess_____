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
    
    enum cellState {
        case sphere
        case cross
        case empty
    }
    
    @IBOutlet weak var sceneView: ARSCNView!
    var previewBox: SCNNode!
    var lastPlaced = SCNNode()
    var original: SCNNode!
    var cube = [[[Cell]]]()
    
    init(sceneView: ARSCNView) {
        self.sceneView = sceneView
        loadAssets()
        
        self.lastPlaced.name = ""
    }
    
    func loadAssets() {
        guard let boxScene = SCNScene(named: "art.scnassets/game.scn") else { fatalError() }
        guard let boxNode = boxScene.rootNode.childNode(withName: "preview", recursively: false)
            else { fatalError() }
        self.previewBox = boxNode
    }
    
    func previewCube(translation: float3) {        
        previewBox.position = SCNVector3(x: translation.x, y: translation.y, z: translation.z)
        sceneView.scene.rootNode.addChildNode(previewBox)
    }
    
    func placeCube(translation: float3) {
        // fill cells in the cube 3D array array
        
        var xval = translation.x - 0.2
        var yval = translation.y
        var zval = translation.z + 0.2
        
        // note to self: upper right name is 202
        
        for i in 0...2 {
            var layerZ = [[Cell]]()
            for j in 0...2 {
                var layerX = [Cell]()
                for k in 0...2 {
                    
                    let cell = Cell(i: i, j: j, k: k, state: Cell.cellState.empty)
                    cell.setPosition(pos: SCNVector3(x: xval, y: yval, z: zval))
                    sceneView.scene.rootNode.addChildNode(cell.cellNode)
                    
                    xval += 0.2
                    layerX.append(cell)
                }
                
                
                xval -= 0.6
                zval -= 0.2
                layerZ.append(layerX)
            }
            zval += 0.6
            yval += 0.2
            cube.append(layerZ)
        }
    }
    
    func placeCell(node: SCNNode, isUser: Bool) -> String {
        
        let tappedCell = getCellfromName(cellIndex: node.name!)
        
        if (isUser) {
            tappedCell.setCellState(state: Cell.cellState.sphere)
        }
        else {
            tappedCell.setCellState(state: Cell.cellState.cross)
        }
        
        tappedCell.setPosition(pos: node.position)
        sceneView.scene.rootNode.replaceChildNode(node, with: tappedCell.cellNode)
        
        return tappedCell.cellName
    }
    
    func previewCell(node: SCNNode) {
        
        if node.name != lastPlaced.name {
            
            if lastPlaced.name != "" {
                sceneView.scene.rootNode.replaceChildNode(lastPlaced, with: original)
            }
            
            original = node
            let previewCell = makeNode(state: cellState.sphere)
            previewCell.position = node.position
            previewCell.name = node.name
            
            sceneView.scene.rootNode.replaceChildNode(node, with: previewCell)
            
            lastPlaced = previewCell
        }
    }
    
    private func getCellfromName(cellIndex: String) -> Cell {
        
        var cellIndexArr = Array(cellIndex)
        
        let i = Int(String(cellIndexArr[0]))!
        let j = Int(String(cellIndexArr[1]))!
        let k = Int(String(cellIndexArr[2]))!
        
        return cube[i][j][k]
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
    
    
    
    public func setPreviewCubeSize()   {
        // update the preview Cube size as user resizes the cube
    }
    
    func makeNode(state: cellState) -> SCNNode {
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
        
        guard let gameScene = SCNScene(named: "art.scnassets/game.scn") else { fatalError() }
        guard let node = gameScene.rootNode.childNode(withName: name, recursively: false)
            else { fatalError() }
        
        
        return node
    }
    
}
