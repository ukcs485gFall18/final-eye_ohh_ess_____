//
//  ViewController.swift
//  AR KIT tutorial
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
    
    private var arDelegate = RootARDelegate()
    private var gestureDelegate = RootGestureDelegate()
    
    var prevLocation = CGPoint(x: 0, y: 0)      // variable to capute prev location
    var shipObj: SCNNode!
    var shipPlaced: Bool = false {  // bool to lock only one ship in the scene
        didSet {
            sceneView.debugOptions = shipPlaced ? [] : [.showFeaturePoints] //Hide Feature points based on ships existence or not.
        }
    }
    
    var rootViewModel: RootViewModel? {
        didSet{
            setupViewModel(with: rootViewModel!)
        }
    }
    
    /*
     New Feature
     Author: Karthik
     This function removes all objects (nodes) placed in the scene
     */
    @IBAction func resetTapped(_ sender: Any) {
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }
        shipPlaced = false
    }
    
    //New Feature
    // Author: Dagmawi
    //This function gets called everytime the user slides the UISlider
    @IBAction func rotate3DObject(_ sender: UISlider) {
        if shipPlaced {
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        sceneView.delegate = arDelegate
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    /*
     This function takes in a scene tap location co-ordinates and adds a box node to the scene
     */
    func addBox(x: Float = 0, y: Float = 0, z: Float = -0.2) {
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        
        let boxNode = SCNNode()
        boxNode.geometry = box
        boxNode.position = SCNVector3(x, y, z)
        addNode(boxNode)
    }
    
    
    
    
    private func setupViewModel(with viewModel: RootViewModel) {
        
        setupPlacementNotification(with: viewModel)
    
    }
    
    private func setupPlacementNotification(with viewModel: RootViewModel) {
        viewModel.notifyPlace = { [weak self] (node) in
            self?.addNode(node)
        }
    }
    
    private func addNode(_ child: SCNNode) {
        sceneView.scene.rootNode.addChildNode(child)
    }
    
    /*
     Author: Karthik
     This function is called when the tap gesture is activated
     */
    
    @objc func addShipToSceneView(withGestureRecognizer recognizer: UIGestureRecognizer) {
//        print("tap")
        let tapLocation = recognizer.location(in: sceneView)
        
        if prevLocation != tapLocation && !shipPlaced {
            
            prevLocation = tapLocation      // set current tap location to prev
            resetTapped(0)                  // simulate reset button to remove prev objects
            
            let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
            
            guard let hitTestResult = hitTestResults.first else { return }
            let translation = hitTestResult.worldTransform.translation
            
            addBox(x: translation.x, y: translation.y, z: translation.z)       // add a box to current location to "preview" ship placement
        }
        
        if (recognizer.state == UIGestureRecognizerState.ended) && !shipPlaced {               // when tap is release we want to place the ship
            resetTapped(0)                                                                     // simulate reset button to remove box node
            
            let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
            
            guard let hitTestResult = hitTestResults.first else { return }
            let translation = hitTestResult.worldTransform.translation
            
            guard let shipScene = SCNScene(named: "art.scnassets/ship.scn") else { fatalError() }
               guard let shipNode = shipScene.rootNode.childNode(withName: "Sphere", recursively: false)
                else { fatalError() }
            
            shipNode.position = SCNVector3(x: translation.x, y: translation.y, z: translation.z)
            //sceneView.scene.rootNode.addChildNode(shipNode)
            addNode(shipNode)
            shipPlaced = true
            
            shipObj = shipNode
        }
    }
    
    /*New Feature
     Author: Karthik
     This function assign the long press gesture with 0 delay to take advantage of on release functionality
     */
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(addShipToSceneView))
        tapGestureRecognizer.minimumPressDuration = 0
        tapGestureRecognizer.delegate = gestureDelegate
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    /*
     New Feature
     Author: Deavin
     This function is called when the pinch gesture is activated
     */
    @objc func pinchToZoom(_ gesture: UIPinchGestureRecognizer) {

        guard let ship = shipObj as? ShipNode else { return }
        if gesture.state == .began || gesture.state == .changed{
            ship.scale(with: Pinch(from: gesture))
            reset(gesture)
        }
    }
    
    private func reset(_ gesture: UIPinchGestureRecognizer) {
        gesture.scale = Gesture.defaultScale
    }
    
    /* New Feature
     Authors: Deavin, Yacob
     This function assign the pinch gesture
     */
    func addPinchGestureToSceneView() {
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchToZoom))
        pinchGestureRecognizer.delegate = gestureDelegate
        sceneView.addGestureRecognizer(pinchGestureRecognizer)
    }
    
}





