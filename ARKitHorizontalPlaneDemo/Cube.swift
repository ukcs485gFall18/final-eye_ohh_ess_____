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
        loadCubeData()
        
        self.lastPlaced.name = ""
    }
    
    func loadCubeData() {
        guard let boxScene = SCNScene(named: "art.scnassets/game.scn") else { fatalError() }
        guard let boxNode = boxScene.rootNode.childNode(withName: "preview", recursively: false)
            else { fatalError() }
        self.previewBox = boxNode
        
        // fill cells in Cube 3D array
        for i in 0...2 {
            var layerZ = [[Cell]]()
            for j in 0...2 {
                var layerX = [Cell]()
                for k in 0...2 {
                    
                    let cell = Cell(i: i, j: j, k: k, state: Cell.cellState.empty)
                    cell.setPosition(pos: SCNVector3(x: 0, y: 0, z: 0))
                    
                    layerX.append(cell)
                }
                
                layerZ.append(layerX)
            }
            cube.append(layerZ)
        }
    }
    
    func removeLastPreviewCube() {
        previewBox.removeFromParentNode()
    }
    
    func previewCube(translation: float3) {        
        previewBox.position = SCNVector3(x: translation.x, y: translation.y, z: translation.z)
        sceneView.scene.rootNode.addChildNode(previewBox)
        
    }
    
    func placeCube(translation: float3) {
        
        // set cell positions in the 3D world
        var xval = translation.x - 0.2
        var yval = translation.y
        var zval = translation.z + 0.2
        
        for i in 0...2 {
            for j in 0...2 {
                for k in 0...2 {
                    let cell = cube[i][j][k]
                    cell.setPosition(pos: SCNVector3(x: xval, y: yval, z: zval))
                    sceneView.scene.rootNode.addChildNode(cell.cellNode)
                    
                    xval += 0.2
                }
                xval -= 0.6
                zval -= 0.2
            }
            zval += 0.6
            yval += 0.2
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
    
    func setPreviewCubeSize()   {
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
    
    func resize(_ gesture: UIPinchGestureRecognizer) {
        print("print")
        for i in 0...2 {
            for j in 0...2 {
                for k in 0...2 {
                    let cell = cube[i][j][k].cellNode!
                    
                    
                    if gesture.state == .began || gesture.state == .changed  {
                        
                        let pinchScaleX: CGFloat = gesture.scale * CGFloat((cell.scale.x))
                        let pinchScaleY: CGFloat = gesture.scale * CGFloat((cell.scale.y))
                        let pinchScaleZ: CGFloat = gesture.scale * CGFloat((cell.scale.z))
                        cell.scale = SCNVector3Make(Float(pinchScaleX), Float(pinchScaleY), Float(pinchScaleZ))
                        gesture.scale = 1
                        
                    }
                    
//                    sceneView.scene.rootNode.addChildNode(cell)
                }
            }
        }
    }
    
}
