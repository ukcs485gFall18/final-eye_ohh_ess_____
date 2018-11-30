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
    
    //var defaultCell = Cell(x: 0, y: 0, z: 0)
    //var cube = [[[Cell]]]()
    
    enum cellState {
        case sphere
        case cross
        case empty
    }
    
    @IBOutlet weak var sceneView: ARSCNView!
    var previewBox: SCNNode!
    var lastPlaced = SCNNode()
    var original: SCNNode!
//    var lastCellName: String = ""
    var cube = [[[Cell]]]()

    var cubePlaced: Bool = false
    var prevLocation = CGPoint(x: 0, y: 0)
    
    var ai = EasyAI()

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
    
    func reset() {
         // remove cell nodes from the scene
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }
        cubePlaced = false
    }
    
    
    func handleCubeTap(withGestureRecognizer recognizer: UIGestureRecognizer, tapLocation: CGPoint){
        
        let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        
        guard let hitTestResult = hitTestResults.first else { return }
        let translation: float3 = hitTestResult.worldTransform.translation
        
        if prevLocation != tapLocation && !cubePlaced {
            prevLocation = tapLocation      // set current tap location to prev
            previewCube(translation: translation)
        }
        
        if (recognizer.state == UIGestureRecognizerState.ended) && !cubePlaced {    // when tap is release we want to place the ship
            placeCube(translation: translation)
        }
    }
    
    
    func previewCube(translation: float3) {
        reset()                  // simulate reset button to remove prev objects
        
        previewBox.position = SCNVector3(x: translation.x, y: translation.y, z: translation.z)
        sceneView.scene.rootNode.addChildNode(previewBox)
    }
    
    func placeCube(translation: float3) {
        reset()                                                           // simulate reset button to remove box node
        
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
        
        cubePlaced = true;
        
    }
    
    
    func handleCellTap(withGestureRecognizer recognizer: UIGestureRecognizer, tapLocation: CGPoint) {
        if recognizer.state == .ended {

            let hits = self.sceneView.hitTest(tapLocation, options: nil)
            
            if !hits.isEmpty {
                let tappedNode = hits.first?.node
                let tappedCell = getCellfromName(cellIndex: tappedNode!.name!)
                
                print(tappedCell.cellName)
                
                tappedCell.setCellState(state: Cell.cellState.sphere)
                tappedCell.setPosition(pos: (tappedNode?.position)!)
                print(cube[0][0][0].state!)
                sceneView.scene.rootNode.replaceChildNode(tappedNode!, with: tappedCell.cellNode)

                
                ai.removeValidMove(cellIndex: tappedCell.cellName)

                let aiMoveCell = getCellfromName(cellIndex: ai.getMove())
                var nodeToReplace: SCNNode!

                sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
                    if node.name == aiMoveCell.cellName {
                        nodeToReplace = node
                    }
                }

                print("AI played" + aiMoveCell.cellName)
                aiMoveCell.setCellState(state: Cell.cellState.cross)
                aiMoveCell.setPosition(pos: (nodeToReplace.position))
                sceneView.scene.rootNode.replaceChildNode(nodeToReplace, with: aiMoveCell.cellNode)
                ai.removeValidMove(cellIndex: aiMoveCell.cellName)
            }
            
        }
        else {
            let hits = self.sceneView.hitTest(tapLocation, options: nil)
            if !hits.isEmpty {
                let tappedNode = hits.first?.node

                if tappedNode!.name != lastPlaced.name {

                    if lastPlaced.name != "" {
                        sceneView.scene.rootNode.replaceChildNode(lastPlaced, with: original)
                    }
                    
                    original = tappedNode
                    let previewCell = makeNode(state: cellState.sphere)
                    previewCell.position = tappedNode!.position
                    previewCell.name = tappedNode!.name
                    
                    sceneView.scene.rootNode.replaceChildNode(tappedNode!, with: previewCell)

                    lastPlaced = previewCell
                    print(lastPlaced.name!)

                }
            }
        }
    }
    

    private func getCellfromName(cellIndex: String) -> Cell {
        
        var cellIndexArr = Array(cellIndex)
        
        let i = Int(String(cellIndexArr[0]))!
        let j = Int(String(cellIndexArr[1]))!
        let k = Int(String(cellIndexArr[2]))!
        
        return cube[i][j][k]
    }
    

    
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
        
//        self.state = state          // set stare to empty, cross or sphere
        
        guard let gameScene = SCNScene(named: "art.scnassets/game.scn") else { fatalError() }
        guard let node = gameScene.rootNode.childNode(withName: name, recursively: false)
            else { fatalError() }
        
        
        return node
    }

}
