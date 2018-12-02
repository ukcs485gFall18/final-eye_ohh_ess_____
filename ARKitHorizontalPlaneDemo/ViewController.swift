//
//  ViewController.swift
//
//  Created by Karthik Nayak, Deavin Hester, Dagmawi Nadew, Yacob Alemneh on 8/30/18.
//  Copyright © 2018 Team - eye_Ohh_ess. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var rotationSlider: UISlider!
    
    var localGame: GameLocal!
    
    @IBAction func rePlace(_ sender: Any) {
        localGame.rePlace()
        setUpSceneView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLighting()
        addTapGestureToSceneView()
        
        addPinchGestureToSceneView()
        
        self.localGame =  GameLocal(sceneView: sceneView)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpSceneView()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    
    func setUpSceneView() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal                  // this tells sceneView to detect horizontal planes
        
        sceneView.session.run(configuration)
        
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showCreases, ARSCNDebugOptions.showWireframe, ARSCNDebugOptions.showBoundingBoxes, ARSCNDebugOptions.showConstraints]
    }
    
    
    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    
    /*
     Author: Karthik
     This function assign the long press gesture with 0 delay to take advantage of on release functionality
     */
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(tapAction))
        tapGestureRecognizer.minimumPressDuration = 0
        tapGestureRecognizer.delegate = self
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    /*
     Author: Karthik
     This function is called when the tap gesture is activated
     */
    @objc func tapAction(withGestureRecognizer recognizer: UIGestureRecognizer) {
        localGame.userTap(withGestureRecognizer: recognizer)
    }
    
    /* New Feature
     Authors: Deavin, Yacob
     This function assign the pinch gesture
     */
    func addPinchGestureToSceneView() {
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchToZoom))
        pinchGestureRecognizer.delegate = self
        sceneView.addGestureRecognizer(pinchGestureRecognizer)
    }
    
    /*
     New Feature
     Author: Deavin
     This function is called when the pinch gesture is activated
     */
    @objc func pinchToZoom(_ gesture: UIPinchGestureRecognizer) {
//        print("pinch")
        localGame.userPinch(gesture)
    }
    
    //
    //    //New Feature
    //    // Author: Dagmawi
    //    //This function gets called everytime the user slides the UISlider
    //    @IBAction func rotate3DObject(_ sender: UISlider) {
    //        if cubePlaced {
    //            sceneView.scene.rootNode.enumerateChildNodes {[weak self] (node, stop) in
    //                self?.rotate(node, with: sender.value)
    //            }
    //        }
    //    }
    
    //New Feature
    //Author: Dagmawi
    //This function rotates the 3D object in the ARSCNView
    //    private func rotate(_ node: SCNNode, with value: Float){
    //        node.eulerAngles.y = value // Changing the Y value makes the 3D object rotate around the y-axis
    //    }
}

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}

extension UIColor {
    open class var transparentLightBlue: UIColor {
        return UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 0.50)
    }
}

extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        // We safely unwrap the anchor argument as an ARPlaneAnchor to get information the flat surface at hand.
        guard let planeAnchor = anchor as? ARPlaneAnchor, !localGame.cubePlaced else { return }
        
        // creating an SCNPlane to visualize the ARPlaneAnchor
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)
        
        // assigning a color to our detected plane
        plane.materials.first?.diffuse.contents = UIColor.transparentLightBlue
        
        // SCNNode with the SCNPlane geometry we just created.
        let planeNode = SCNNode(geometry: plane)
        
        // getting a position for out plane to be places
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x,y,z)
        planeNode.eulerAngles.x = -.pi / 2
        
        // adding the planeNode as the child node onto the newly added SceneKit node.
        node.addChildNode(planeNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // unwraping the anchor argument as ARPlaneAnchor, the node’s first child node, and the planeNode’s geometry as SCNPlane
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
        
        // we update the plane’s width and height using the planeAnchor extent’s x and z properties.
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.height = height
        
        // updatong the planeNode’s position
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
    }
}


extension ViewController: UIGestureRecognizerDelegate {
    //New Functionality
    //Author: Yacob
    //Delegate function Allows view to recognize multiple gestures simultaneously
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
