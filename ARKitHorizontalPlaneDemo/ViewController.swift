//
//  ViewController.swift
//
//  Created by Karthik Nayak, Deavin Hester, Dagmawi Nadew, Yacob Alemneh on 8/30/18.
//  Copyright © 2018 Team - eye_Ohh_ess. All rights reserved.
//

import UIKit
import ARKit
import SceneKit
import AVFoundation
import os.signpost

class ViewController: UIViewController {
    
    enum SessionState {
        case setup
        case lookingForSurface
        case adjustingBoard
        case placingBoard
        case waitingForBoard
        case localizingToBoard
        case setupLevel
        case gameInProgress
        
        var localizedInstruction: String? {
            
            switch self {
            case .lookingForSurface:
                return NSLocalizedString("Find a flat surface to place the game.", comment: "")
            case .placingBoard:
                return NSLocalizedString("Scale, rotate or move the board.", comment: "")
            case .adjustingBoard:
                return NSLocalizedString("Make adjustments and tap to continue.", comment: "")
            case .gameInProgress:
                if UserDefaults.standard.hasOnboarded {
                    return nil
                } else {
                    return NSLocalizedString("Move closer to a slingshot.", comment: "")
                }
            case .setupLevel:
                return nil
            case .waitingForBoard:
                return NSLocalizedString("Synchronizing world map…", comment: "")
            case .localizingToBoard:
                return NSLocalizedString("Point the camera towards the table.", comment: "")
            case .setup:
                return nil
            }
        }
    }
    
    @IBOutlet var sceneView: ARSCNView!

//    @IBOutlet weak var overlayView: UIView!
//    @IBOutlet weak var exitGameButton: UIButton!
//    @IBOutlet weak var settingsButton: UIButton!
    
    // Gesture recognizers
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet var pinchGestureRecognizer: UIPinchGestureRecognizer!
    @IBOutlet var rotateGestureRecognizer: UIRotationGestureRecognizer!
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    
    @IBOutlet weak var instructionLabel: UILabel!
    
//    @IBOutlet weak var networkDelayText: UILabel!
    @IBOutlet weak var notificationLabel: UILabel!
    
    
    var gameManager: GameBoard? {
        didSet {
            guard let manager = gameManager else {
                sessionState = .setup
                return
            }
            
//            if manager.isNetworked && !manager.isServer {
//                sessionState = .waitingForBoard
//            } else {
//                sessionState = .lookingForSurface
//            }
            
            sessionState = .lookingForSurface
//            manager.delegate = self
        }
    }
    
    // DDD
    var sessionState: SessionState = .setup {
        didSet {
            guard oldValue != sessionState else { return }
            
            os_log(.info, "session state changed to %s", "\(sessionState)")
            configureView()
            configureARSession()
        }
    }
    
    // DDD
    var isSessionInterrupted = false {
        didSet {
            if isSessionInterrupted  {
                instructionLabel.isHidden = false
                instructionLabel.text = NSLocalizedString("Point the camera towards the table.", comment: "")
            } else {
                if let localizedInstruction = sessionState.localizedInstruction {
                    instructionLabel.isHidden = false
                    instructionLabel.text = localizedInstruction
                } else {
                    instructionLabel.isHidden = true
                }
            }
        }
    }
    
    // used when state is localizingToWorldMap or localizingToSavedMap
    var targetWorldMap: ARWorldMap?
    
    var gameBoard = GameBoard()
    
    // Root node of the level
    var renderRoot = SCNNode()
    
    var canAdjustBoard: Bool {
        return sessionState == .placingBoard || sessionState == .adjustingBoard
    }
    
    var attemptingBoardPlacement: Bool {
        return sessionState == .lookingForSurface || sessionState == .placingBoard
    }
    
    var screenCenter: CGPoint {
        let bounds = sceneView.bounds
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.scene.rootNode.addChildNode(gameBoard)
        
        sessionState = .setup
        sceneView.session.delegate = self
        
        instructionLabel.clipsToBounds = true
        instructionLabel.layer.cornerRadius = 8.0
        
        notificationLabel.clipsToBounds = true
        notificationLabel.layer.cornerRadius = 8.0
        
        renderRoot.name = "_renderRoot"
        sceneView.scene.rootNode.addChildNode(renderRoot)
        
        

        
        
        configureLighting()
//        addTapGestureToSceneView()
//
//        addPinchGestureToSceneView()
        
//        self.localGame =  GameLocal(sceneView: sceneView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureARSession()
        configureView()
        setUpSceneView()
    }
    
    
    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    func setUpSceneView() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal                  // this tells sceneView to detect horizontal planes
        
        sceneView.session.run(configuration)
        
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    // MARK: - Configuration
    func configureView() {
        dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
        
        var debugOptions: SCNDebugOptions = []
        // mutate and append to debugOptions during debugging
        
        sceneView.debugOptions = debugOptions
        
        // smooth the edges by rendering at higher resolution
        // defaults to none on iOS, use on faster GPUs
        // 0, 2, 4 on iOS, 8, 16x on macOS
        sceneView.antialiasingMode = UserDefaults.standard.antialiasingMode ? .multisampling4X : .none
        
        os_log(.info, "antialiasing set to: %s", UserDefaults.standard.antialiasingMode ? "4x" : "none")
        
        if let localizedInstruction = sessionState.localizedInstruction {
            instructionLabel.isHidden = false
            instructionLabel.text = localizedInstruction
        } else {
            instructionLabel.isHidden = true
        }
        
//        exitGameButton.setImage(#imageLiteral(resourceName: "close"), for: .normal)
//        exitGameButton.isHidden = sessionState == .setup
        
    }
    
    func configureARSession() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.isAutoFocusEnabled = UserDefaults.standard.autoFocus
        let options: ARSession.RunOptions
        switch sessionState {
        case .setup:
            // in setup
            os_log(.info, "AR session paused")
            sceneView.session.pause()
            return
        case .lookingForSurface, .waitingForBoard:
            // both server and client, go ahead and start tracking the world
            configuration.planeDetection = [.horizontal]
            options = [.resetTracking, .removeExistingAnchors]
            
            // Only reset session if not already running
            if sceneView.isPlaying {
                return
            }
        case .placingBoard, .adjustingBoard:
            // we've found at least one surface, but should keep looking.
            // so no change to the running session
            return
        case .localizingToBoard:
            guard let targetWorldMap = targetWorldMap else { os_log(.error, "should have had a world map"); return }
            configuration.initialWorldMap = targetWorldMap
            configuration.planeDetection = [.horizontal]
            options = [.resetTracking, .removeExistingAnchors]
            gameBoard.anchor = targetWorldMap.boardAnchor
            if let boardAnchor = gameBoard.anchor {
                gameBoard.simdTransform = boardAnchor.transform
                gameBoard.simdScale = float3( Float(boardAnchor.size.width) )
            }
            gameBoard.hideBorder(duration: 0)
            
        case .setupLevel:
            // more init
            return
        case .gameInProgress:
            // The game is in progress, no change to the running session
            return
        }
        
        // Turning light estimation off to test PBR on SceneKit file
        configuration.isLightEstimationEnabled = false
        
        os_log(.info, "configured AR session")
        sceneView.session.run(configuration, options: options)
    }
    
    func updateGameBoard(frame: ARFrame) {
        
        if sessionState == .setupLevel {
            // this will advance the session state
            //            setupLevel()
            return
        }
        
        // Only automatically update board when looking for surface or placing board
        guard attemptingBoardPlacement else {
            return
        }
        
        // Make sure this is only run on the render thread
        
        if gameBoard.parent == nil {
            sceneView.scene.rootNode.addChildNode(gameBoard)
        }
        
        // Perform hit testing only when ARKit tracking is in a good state.
        if case .normal = frame.camera.trackingState {
            
            if let result = sceneView.hitTest(screenCenter, types: [.estimatedHorizontalPlane, .existingPlaneUsingExtent]).first {
                // Ignore results that are too close to the camera when initially placing
                guard result.distance > 0.5 || sessionState == .placingBoard else { return }
                
                sessionState = .placingBoard
                gameBoard.update(with: result, camera: frame.camera)
            } else {
                sessionState = .lookingForSurface
                if !gameBoard.isBorderHidden {
                    gameBoard.hideBorder()
                }
            }
        }
    }
    
}


// MARK: - SCNViewDelegate
extension ViewController: SCNSceneRendererDelegate {
    // This is the ordering of delegate calls
    // https://developer.apple.com/documentation/scenekit/scnscenerendererdelegate
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        os_signpost(.begin, log: .render_loop, name: .render_loop, signpostID: .render_loop,
                    "Render loop started")
        os_signpost(.begin, log: .render_loop, name: .logic_update, signpostID: .render_loop,
                    "Game logic update started")
        
     
//            GameTime.updateAtTime(time: time)
            
            if let pointOfView = sceneView.pointOfView {
                // make a copy of the camera data that other threads can access
                // ARKit has updated the transform right before this
                
                // these can use the pointOfView since the render thread scales/unscales the camera around rendering
 
                

                
                DispatchQueue.main.async {
                    if self.sessionState == .gameInProgress {

                    }
                }
            }

        
        os_signpost(.end, log: .render_loop, name: .logic_update, signpostID: .render_loop,
                    "Game logic update finished")
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didApplyConstraintsAtTime time: TimeInterval) {
        os_signpost(.begin, log: .render_loop, name: .post_constraints_update, signpostID: .render_loop,
                    "Post constraints update started")
       
            // scale up/down the camera to render space
//            gameManager.scaleCameraToRender()
        


        
        
        os_signpost(.end, log: .render_loop, name: .post_constraints_update, signpostID: .render_loop,
                    "Post constraints update finished")
    }
    
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        os_signpost(.begin, log: .render_loop, name: .render_scene, signpostID: .render_loop,
                    "Rendering scene started")
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        // update visibility properties in renderloop because we have to scale the physics world down to render properly
            

            
            // return the pointOfView back from scaled space
//            gameManager.scaleCameraToSimulation()
    
        
        os_signpost(.end, log: .render_loop, name: .render_scene, signpostID: .render_loop,
                    "Rendering scene finished")
        os_signpost(.end, log: .render_loop, name: .render_loop, signpostID: .render_loop,
                    "Render loop finished")
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didApplyAnimationsAtTime time: TimeInterval) {
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
        
    }
}

// MARK: - ARSessionDelegate
extension ViewController: ARSessionDelegate {
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
        // Update game board placement in physical world
        if gameManager != nil {
            // this is main thread calling into init code
            updateGameBoard(frame: frame)
        }
        updateGameBoard(frame: frame)
        
        // Update mapping status for saving maps
//        updateMappingStatus(frame.worldMappingStatus)
    }
}


















    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        sceneView.session.pause()
//    }
    
    
//    func setUpSceneView() {
//        let configuration = ARWorldTrackingConfiguration()
//        configuration.planeDetection = .horizontal                  // this tells sceneView to detect horizontal planes
//
//        sceneView.session.run(configuration)
//
//        sceneView.delegate = self
//        sceneView.scene.rootNode.addChildNode(gameBoard)
//        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
//    }
//
    
    

    
    //
    //    @IBOutlet weak var resetButton: UIButton!
    //
    //
    //
    //    var localGame: GameLocal!
    //
    //    @IBAction func rePlace(_ sender: Any) {
    //        localGame.rePlace()
    //        setUpSceneView()
    //    }
    //

    
    
    /*
     Author: Karthik
     This function assign the long press gesture with 0 delay to take advantage of on release functionality
     */
//    func addTapGestureToSceneView() {
//        let tapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(tapAction))
//        tapGestureRecognizer.minimumPressDuration = 0
//        tapGestureRecognizer.delegate = self
//        sceneView.addGestureRecognizer(tapGestureRecognizer)
//    }
//    
    /*
     Author: Karthik
     This function is called when the tap gesture is activated
     */
//    @objc func tapAction(withGestureRecognizer recognizer: UIGestureRecognizer) {
//        localGame.userTap(withGestureRecognizer: recognizer)
//    }
    
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

//}

//extension float4x4 {
//    var translation: float3 {
//        let translation = self.columns.3
//        return float3(translation.x, translation.y, translation.z)
//    }
//}

//extension UIColor {
//    open class var transparentLightBlue: UIColor {
//        return UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 0.50)
//    }
//}

//extension ViewController: ARSCNViewDelegate {
//
//    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
//
//        // We safely unwrap the anchor argument as an ARPlaneAnchor to get information the flat surface at hand.
//        guard let planeAnchor = anchor as? ARPlaneAnchor, !localGame.cubePlaced else { return }
//
//        // creating an SCNPlane to visualize the ARPlaneAnchor
//        let width = CGFloat(planeAnchor.extent.x)
//        let height = CGFloat(planeAnchor.extent.z)
//        let plane = SCNPlane(width: width, height: height)
//
//        // assigning a color to our detected plane
//        plane.materials.first?.diffuse.contents = UIColor.transparentLightBlue
//
//        // SCNNode with the SCNPlane geometry we just created.
//        let planeNode = SCNNode(geometry: plane)
//
//        // getting a position for out plane to be places
//        let x = CGFloat(planeAnchor.center.x)
//        let y = CGFloat(planeAnchor.center.y)
//        let z = CGFloat(planeAnchor.center.z)
//        planeNode.position = SCNVector3(x,y,z)
//        planeNode.eulerAngles.x = -.pi / 2
//
//        // adding the planeNode as the child node onto the newly added SceneKit node.
//        node.addChildNode(planeNode)
//    }
//
//    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
//        // unwraping the anchor argument as ARPlaneAnchor, the node’s first child node, and the planeNode’s geometry as SCNPlane
//        guard let planeAnchor = anchor as?  ARPlaneAnchor,
//            let planeNode = node.childNodes.first,
//            let plane = planeNode.geometry as? SCNPlane
//            else { return }
//
//        // we update the plane’s width and height using the planeAnchor extent’s x and z properties.
//        let width = CGFloat(planeAnchor.extent.x)
//        let height = CGFloat(planeAnchor.extent.z)
//        plane.width = width
//        plane.height = height
//
//        // updatong the planeNode’s position
//        let x = CGFloat(planeAnchor.center.x)
//        let y = CGFloat(planeAnchor.center.y)
//        let z = CGFloat(planeAnchor.center.z)
//        planeNode.position = SCNVector3(x, y, z)
//    }
//
//
//}

//extension ViewController: ARSessionDelegate {
//
//    func session(_ session: ARSession, didUpdate frame: ARFrame) {
//
//        // Update game board placement in physical world
//        if gameManager != nil {
//            // this is main thread calling into init code
//            updateGameBoard(frame: frame)
//        }
//
//    }
//}
//
//extension ViewController: ARSCNViewDelegate {
//
//    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
//        if anchor == gameBoard.anchor {
//            // If board anchor was added, setup the level.
//            DispatchQueue.main.async {
//                if self.sessionState == .localizingToBoard {
//                    self.sessionState = .setupLevel
//                }
//            }
//
//            // We already created a node for the board anchor
//            return gameBoard
//        } else {
//            // Ignore all other anchors
//            return nil
//        }
//    }
//
//    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
//        if let boardAnchor = anchor as? BoardAnchor {
//            // Update the game board's scale from the board anchor
//            // The transform will have already been updated - without the scale
//            node.simdScale = float3( Float(boardAnchor.size.width) )
//        }
//    }
//}
//
//
//extension ViewController: UIGestureRecognizerDelegate {
//    //New Functionality
//    //Author: Yacob
//    //Delegate function Allows view to recognize multiple gestures simultaneously
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
//}
