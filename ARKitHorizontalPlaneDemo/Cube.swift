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
    
    @IBOutlet weak var sceneView: ARSCNView!
    var previewBox: SCNNode!
    var cube = [[[SCNNode]]]()

    var cubePlaced: Bool = false
    var prevLocation = CGPoint(x: 0, y: 0)

    init(sceneView: ARSCNView) {
        self.sceneView = sceneView
        loadAssets()
    }
    
    func loadAssets() {
        guard let boxScene = SCNScene(named: "art.scnassets/ship.scn") else { fatalError() }
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
            var layerZ = [[SCNNode]]()
            for j in 0...2 {
                var layerX = [SCNNode]()
                for k in 0...2 {
                    
                    guard let shipScene = Cell(named: "art.scnassets/ship.scn") else { fatalError() }
                    guard let shipNode = shipScene.rootNode.childNode(withName: "Cell-Empty", recursively: false)
                        else { fatalError() }
                    
                    shipNode.position = SCNVector3(x: xval, y: yval, z: zval)
                    sceneView.scene.rootNode.addChildNode(shipNode)
                    shipNode.name = String(i) + String(j) + String(k)
                    
                    //  print(String(i) + String(j) + String(k))
                    xval += 0.2
                    layerX.append(shipNode)
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

                let cubeIndex: String = tappedNode!.name!

                print(cubeIndex)
                print("TAPPPPPED!!!")

                var moveArr = Array(cubeIndex)

                let x = Int(String(moveArr[0]))!
                let y = Int(String(moveArr[1]))!
                let z = Int(String(moveArr[2]))!


                guard let shipScene = SCNScene(named: "art.scnassets/ship.scn") else { fatalError() }
                guard let ball = shipScene.rootNode.childNode(withName: "Cube", recursively: false)
                    else { fatalError() }

                ball.position = cube[x][y][z].position
                sceneView.scene.rootNode.addChildNode(ball)
                ball.name = cube[x][y][z].name

                sceneView.scene.rootNode.replaceChildNode(cube[x][y][z], with: ball)
                cube[x][y][z] = ball
            }
        }
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

}
