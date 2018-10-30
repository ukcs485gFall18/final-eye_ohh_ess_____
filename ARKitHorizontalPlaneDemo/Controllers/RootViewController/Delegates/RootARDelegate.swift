//
//  RootARDelegate.swift
//  ARKitHorizontalPlaneDemo
//
//  Created by Dagmawi Nadew-Assefa on 10/30/18.
//  Copyright © 2018 eye_Ohh_ess. All rights reserved.
//

import ARKit


class RootARDelegate: NSObject, ARSCNViewDelegate {
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        // MARK:- We safely unwrap the anchor argument as an ARPlaneAnchor to get information the flat surface at hand.
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        node.addChildNode(Node(with: planeAnchor))
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        // MARK:- unwraping the anchor argument as ARPlaneAnchor, the node’s first child node, and the planeNode’s geometry as SCNPlane
        
        guard let planeAnchor = anchor as? ARPlaneAnchor,
            let planeNode = node.childNodes.first as? Node ,
            let plane = planeNode.geometry as? Plane
            else { return }

        plane.updateDimension(with: planeAnchor)
        planeNode.updatePosition(for: planeAnchor)
    }
}
