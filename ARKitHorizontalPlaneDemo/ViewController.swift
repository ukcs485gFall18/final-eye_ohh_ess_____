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
    
    
    var prevLocation = CGPoint(x: 0, y: 0)      // variable to capute prev location
    var shipObj: SCNNode!
    var boxObj: SCNNode!
    var cubePlaced: Bool = false {  // bool to lock only one ship in the scene
        didSet {
            sceneView.debugOptions = cubePlaced ? [] : [.showFeaturePoints] //Hide Feature points based on ships existence or not.
        }
    }
    
    /*
     Author: Karthik
     This function removes all objects (nodes) placed in the scene
     */
    @IBAction func resetTapped(_ sender: Any) {
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }
        cubePlaced = false
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadAssets()
        configureLighting()
        addTapGestureToSceneView()
        
        addPinchGestureToSceneView()
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
    

    func loadAssets() {
        guard let boxScene = SCNScene(named: "art.scnassets/ship.scn") else { fatalError() }
        guard let boxNode = boxScene.rootNode.childNode(withName: "preview", recursively: false)
            else { fatalError() }
        self.boxObj = boxNode
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
        
        if !cubePlaced {
            placeCube(withGestureRecognizer: recognizer, tapLocation: tapLocation)
        }
            
        else {
            if recognizer.state == .ended {
                
                let hits = self.sceneView.hitTest(tapLocation, options: nil)
                if !hits.isEmpty {
                    let tappedNode = hits.first?.node
                    print(tappedNode?.name ?? "...")
                    print("TAPPPPPED!!!")
                }
            }
        }
    }
    
    
    func placeCube(withGestureRecognizer recognizer: UIGestureRecognizer, tapLocation: CGPoint){
        
        let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        
        guard let hitTestResult = hitTestResults.first else { return }
        let translation: float3 = hitTestResult.worldTransform.translation
        
        if prevLocation != tapLocation && !cubePlaced {
            prevLocation = tapLocation      // set current tap location to prev
            PreviewCube(translation: translation)
        }
        
        if (recognizer.state == UIGestureRecognizerState.ended) && !cubePlaced {    // when tap is release we want to place the ship
            PlaceCube(translation: translation)
        }
    }
    
    
    func PreviewCube(translation: float3) {
        resetTapped(0)                  // simulate reset button to remove prev objects
        
        boxObj.position = SCNVector3(x: translation.x, y: translation.y, z: translation.z)
        sceneView.scene.rootNode.addChildNode(boxObj)
    }
    
    func PlaceCube(translation: float3) {
        resetTapped(0)                                                          // simulate reset button to remove box node
        
        var xval = translation.x - 0.2
        var yval = translation.y
        var zval = translation.z + 0.2
        
        // note to self: upper right name is 202
        for i in 0...2 {
            for j in 0...2 {
                for k in 0...2 {
                    
                    guard let shipScene = SCNScene(named: "art.scnassets/ship.scn") else { fatalError() }
                    guard let shipNode = shipScene.rootNode.childNode(withName: "Cube", recursively: false)
                        else { fatalError() }
                    
                    shipNode.position = SCNVector3(x: xval, y: yval, z: zval)
                    sceneView.scene.rootNode.addChildNode(shipNode)
                    shipNode.name = String(i) + String(j) + String(k)
                    self.shipObj = shipNode
                    //                            print(String(i) + String(j) + String(k))
                    xval += 0.2
                }
                xval -= 0.6
                zval -= 0.2
            }
            zval += 0.6
            yval += 0.2
        }
        
        cubePlaced = true;
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
        guard let ship = shipObj else { return }
        if gesture.state == .began || gesture.state == .changed{
            
            let pinch = [Float(gesture.scale) * ship.scale.x,
                         Float(gesture.scale) * ship.scale.y,
                         Float(gesture.scale) * ship.scale.z]
            ship.scale = SCNVector3Make(pinch[0], pinch[1], pinch[2])
            gesture.scale = 1
        }
    }
    
    //New Feature
    // Author: Dagmawi
    //This function gets called everytime the user slides the UISlider
    @IBAction func rotate3DObject(_ sender: UISlider) {
        if cubePlaced {
            sceneView.scene.rootNode.enumerateChildNodes {[weak self] (node, stop) in
                self?.rotate(node, with: sender.value)
            }
        }
    }
    
    //New Feature
    //Author: Dagmawi
    //This function rotates the 3D object in the ARSCNView
    private func rotate(_ node: SCNNode, with value: Float){
        node.eulerAngles.y = value // Changing the Y value makes the 3D object rotate around the y-axis
    } 
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
        guard let planeAnchor = anchor as? ARPlaneAnchor, !cubePlaced else { return }
        
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
