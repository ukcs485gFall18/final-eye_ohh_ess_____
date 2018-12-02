//
//  GameLocal.swift
//  ARKitHorizontalPlaneDemo
//
//  Created by Karthik on 11/30/18.
//  Copyright © 2018 eye_Ohh_ess. All rights reserved.
//

import Foundation
import UIKit
import ARKit


class GameLocal {
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    var cube: Cube!
    var availablePositions: [String] = []
    
    var ai: EasyAI!
    
    var prevLocation = CGPoint(x: 0, y: 0)
    var cubePlaced: Bool = false
    
    func stopPlaneDetection() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = []               // this tells sceneView to detect horizontal planes
        sceneView.debugOptions = []
        sceneView.session.run(configuration)
    }
    
    init(sceneView: ARSCNView) {
        self.sceneView = sceneView
        
        self.cube = Cube(sceneView: sceneView)
        createAvailablePositions()
        
    }
    
    private func createAvailablePositions(){
        for i in 0...2 {
            for j in 0...2 {
                for k in 0...2 {
                    self.availablePositions.append(String(i) + String(j) + String(k))
                }
            }
        }
    }
    
    func rePlace() {
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }
        
        cubePlaced = false
    }
    
    func userTap(withGestureRecognizer recognizer: UIGestureRecognizer) {
        let tapLocation: CGPoint = recognizer.location(in: sceneView)
        let isTapComplete = recognizer.state == UIGestureRecognizerState.ended
        
        if !cubePlaced {
            handleCubePlacement(tapLocation: tapLocation, isTapComplete: isTapComplete)
        }
        else {
            handleGameMove(tapLocation: tapLocation, isTapComplete: isTapComplete)
        }
    }
    
    func userPinch(_ recognizer: UIPinchGestureRecognizer) {
        cube.resize(recognizer)
    }
    
    private func handleGameMove(tapLocation: CGPoint, isTapComplete: Bool) {
        let hitTestResults = sceneView.hitTest(tapLocation, options: nil)
        
        guard let tappedNode = hitTestResults.first?.node else { return }
        guard let nodeName = tappedNode.name else { return }
        
        if (isTapComplete) && availablePositions.contains(nodeName) {    // when tap is release we want to place the cells
            
            let userMove = cube.placeCell(node: tappedNode, isUser: true)
            removeValidMove(cellIndex: userMove)
            
            //                let aiMove = ai.getMove(availablePositions: availablePositions)
            let aiMove = availablePositions.randomElement()!
            removeValidMove(cellIndex: aiMove)
            
            print("User played" + userMove)
            print("AI played" + aiMove)
            
            sceneView.scene.rootNode.enumerateChildNodes { (nodeToReplace, stop) in
                if nodeToReplace.name == aiMove {
                    cube.placeCell(node: nodeToReplace, isUser: false)
                }
            }
            
        }
            
        else if availablePositions.contains(nodeName) {
            cube.previewCell(node: tappedNode)
        }
    }
    
    private func handleCubePlacement(tapLocation: CGPoint, isTapComplete: Bool){
        cube.removeLastPreviewCube()
        let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        
        guard let hitTestResult = hitTestResults.first else { return }
        let translation: float3 = hitTestResult.worldTransform.translation
        
        if (isTapComplete) {                // when tap is release we want to place the cube
            rePlace()                       // remove plane
            cube.placeCube(translation: translation)
            cubePlaced = true
            stopPlaneDetection()
        }
        else if prevLocation != tapLocation {
            prevLocation = tapLocation      // set current tap location to prev
            cube.previewCube(translation: translation)
        }
    }
    
    private func removeValidMove(cellIndex: String) {
        let idx = availablePositions.firstIndex(of: cellIndex)
        availablePositions.remove(at: idx!)
    }
    
}
