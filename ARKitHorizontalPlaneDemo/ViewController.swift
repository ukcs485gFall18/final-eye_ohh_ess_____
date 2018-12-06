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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var exitGameButton: UIButton!
    
    
    var targetWorldMap: ARWorldMap?
    
    
    
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var rotationSlider: UISlider!
    
    var gameBoard = GameBoard()
    
    var localGame: GameLocal!
    
    @IBAction func rePlace(_ sender: Any) {
        localGame.rePlace()
        setUpSceneView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLighting()
        addTapGestureToSceneView()
        
        //        addPinchGestureToSceneView()
        
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
        localGame.userTap(withGestureRecognizer: recognizer)
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
    
    
    // MARK: - Configuration
    func configureView() {
        dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
        
        var debugOptions: SCNDebugOptions = []
        
        
        sceneView.debugOptions = debugOptions
        
        // perf stats

        
//        trackingStateLabel.isHidden = !UserDefaults.standard.showTrackingState
        
        // smooth the edges by rendering at higher resolution
        // defaults to none on iOS, use on faster GPUs
        // 0, 2, 4 on iOS, 8, 16x on macOS
        sceneView.antialiasingMode = UserDefaults.standard.antialiasingMode ? .multisampling4X : .none
        
        os_log(.info, "antialiasing set to: %s", UserDefaults.standard.antialiasingMode ? "4x" : "none")
        
//        if let localizedInstruction = sessionState.localizedInstruction {
//            instructionLabel.isHidden = false
//            instructionLabel.text = localizedInstruction
//        } else {
//            instructionLabel.isHidden = true
//        }
        
        if sessionState == .waitingForBoard {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        
 

        exitGameButton.setImage(#imageLiteral(resourceName: "close"), for: .normal)

        
        exitGameButton.isHidden = sessionState == .setup
        
        configureMappingUI()
//        configureRelocalizationHelp()
    }
    
    // MARK: Saving and Loading Maps
    func configureMappingUI() {
        let showMappingState = sessionState != .gameInProgress &&
            sessionState != .setup &&
            sessionState != .localizingToBoard
        
//        mappingStateLabel.isHidden = !showMappingState
//        saveButton.isHidden = sessionState == .setup
//        loadButton.isHidden = sessionState == .setup
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
    
    
    var sessionState: SessionState = .setup {
        didSet {
            guard oldValue != sessionState else { return }
            
            os_log(.info, "session state changed to %s", "\(sessionState)")
            configureView()
            configureARSession()
        }
    }
}

//extension float4x4 {
//    var translation: float3 {
//        let translation = self.columns.3
//        return float3(translation.x, translation.y, translation.z)
//    }
//}

extension UIColor {
    open class var transparentLightBlue: UIColor {
        return UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 0.50)
    }
}

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

extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        if anchor == gameBoard.anchor {
            // If board anchor was added, setup the level.
            DispatchQueue.main.async {
                if self.sessionState == .localizingToBoard {
                    self.sessionState = .setupLevel
                }
            }
            
            // We already created a node for the board anchor
            return gameBoard
        } else {
            // Ignore all other anchors
            return nil
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let boardAnchor = anchor as? BoardAnchor {
            // Update the game board's scale from the board anchor
            // The transform will have already been updated - without the scale
            node.simdScale = float3( Float(boardAnchor.size.width) )
        }
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
