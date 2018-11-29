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

    var cube: Cube!
    
    /*
     Author: Karthik
     This function removes all objects (nodes) placed in the scene
     */
    @IBAction func resetTapped(_ sender: Any) {
        cube.reset()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLighting()
        addTapGestureToSceneView()
        
//        addPinchGestureToSceneView()
        self.cube =  Cube(sceneView: sceneView)
        cube.loadAssets()
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
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
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

        let tapLocation: CGPoint = recognizer.location(in: sceneView)
        
        if !cube.cubePlaced {
            cube.handleCubeTap(withGestureRecognizer: recognizer, tapLocation: tapLocation)
        }

        else {
            cube.handleCellTap(withGestureRecognizer: recognizer, tapLocation: tapLocation)
        }
    }

    /* New Feature
     Authors: Deavin, Yacob
     This function assign the pinch gesture
     */
//    func addPinchGestureToSceneView() {
//        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchToZoom))
//        pinchGestureRecognizer.delegate = self
//        sceneView.addGestureRecognizer(pinchGestureRecognizer)
//    }
    
    /*
     New Feature
     Author: Deavin
     This function is called when the pinch gesture is activated
     */
//    @objc func pinchToZoom(_ gesture: UIPinchGestureRecognizer) {
//        //        print("pinch")
//        guard let ship = shipObj else { return }
//        if gesture.state == .began || gesture.state == .changed{
//
//            let pinch = [Float(gesture.scale) * ship.scale.x,
//                         Float(gesture.scale) * ship.scale.y,
//                         Float(gesture.scale) * ship.scale.z]
//            ship.scale = SCNVector3Make(pinch[0], pinch[1], pinch[2])
//            gesture.scale = 1
//        }
//    }
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
        guard let planeAnchor = anchor as? ARPlaneAnchor, !cube.cubePlaced else { return }
        
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
