/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Responsible for tracking the state of the game: which objects are where, who's in the game, etc.
*/

import Foundation
import SceneKit
import GameplayKit
import simd
import AVFoundation
import os.signpost

struct GameState {
    var teamACatapults = 0
    var teamBCatapults = 0

//    mutating func add(_ catapult: Catapult) {
//        switch catapult.team {
//        case .teamA: teamACatapults += 1
//        case .teamB: teamBCatapults += 1
//        default: break
//        }
//    }
}

protocol GameManagerDelegate: class {
//    func manager(_ manager: GameManager, received: BoardSetupAction, from: Player)
    func manager(_ manager: GameManager, joiningPlayer player: Player)
    func manager(_ manager: GameManager, leavingPlayer player: Player)
    func manager(_ manager: GameManager, joiningHost host: Player)
    func manager(_ manager: GameManager, leavingHost host: Player)
    func managerDidStartGame(_ manager: GameManager)
    func managerDidWinGame(_ manager: GameManager)
    func manager(_ manager: GameManager, hasNetworkDelay: Bool)
    func manager(_ manager: GameManager, updated gameState: GameState)
}

/// - Tag: GameManager
class GameManager: NSObject {
    
    // actions coming from the main thread/UI layer
//    struct TouchEvent {
//        var type: TouchType
//        var camera: Ray
//    }
    
    // interactions with the scene must be on the main thread
//    let level: GameLevel
    private let scene: SCNScene
//    private let levelNode: SCNNode
    
    // use this to access the simulation scaled camera
    private(set) var pointOfViewSimulation: SCNNode

    // these come from ARSCNView currentlys
//    let physicsWorld: SCNPhysicsWorld
    private var pointOfView: SCNNode // can be in sim or render space
    
    private var gameBoard: GameBoard?
//    private var tableBoxObject: GameObject?
    
    // don't execute any code from SCNView renderer until this is true
    private(set) var isInitialized = false

    // progress of the game
    private(set) var gameState = GameState()

//    private var gamedefs: [String: Any]

    
//    private let session: NetworkSession?


    private let catapultsLock = NSLock()
//    private var gameCommands = [GameCommand]()
    private let commandsLock = NSLock()
//    private var touchEvents = [TouchEvent]()
    private let touchEventsLock = NSLock()

//    private var categories = [String: [GameObject]] ()  // this object can be used to group like items if their gamedefs include a category
    
    let currentPlayer = UserDefaults.standard.myself

//    let isNetworked: Bool
//    let isServer: Bool

//    init(sceneView: SCNView, session: NetworkSession?)
    init(sceneView: SCNView) {
        
        // make our own scene instead of using the incoming one
        self.scene = sceneView.scene!
        

        // this is a node, that isn't attached to the ARSCNView
        self.pointOfView = sceneView.pointOfView!
        self.pointOfViewSimulation = pointOfView.clone()
        

//        self.session = session



        // init entity system
//        gamedefs = GameObject.loadGameDefs(file: "gameassets.scnassets/data/entities_def"

//        self.isNetworked = session != nil
//        self.isServer = session?.isServer ?? true // Solo game act like a server
        
        super.init()
        
//        self.session?.delegate = self
    }
    
    func unload() {

    }
    
    deinit {
        unload()
    }

//    weak var delegate: GameManagerDelegate?

//    func send(boardAction: BoardSetupAction) {
//        session?.send(action: .boardSetup(boardAction))
//    }
//
//    func send(boardAction: BoardSetupAction, to player: Player) {
//        session?.send(action: .boardSetup(boardAction), to: player)
//    }
//
//    func send(gameAction: GameAction) {
//        session?.send(action: .gameAction(gameAction))
//    }

    // MARK: - processing touches
//    func handleTouch(_ type: TouchType) {
//        guard !UserDefaults.standard.spectator else { return }
//        touchEventsLock.lock(); defer { touchEventsLock.unlock() }
//        touchEvents.append(TouchEvent(type: type, camera: lastCameraInfo.ray))
//    }

//    var lastCameraInfo = CameraInfo(transform: .identity)
//    func updateCamera(cameraInfo: CameraInfo) {
//        if gameCamera == nil {
//            // need the real render camera in order to set rendering state
//            let camera = pointOfView
//            camera.name = "GameCamera"
//            gameCamera = GameCamera(camera)
//            _ = initGameObject(for: camera)
//
//            gameCamera?.updateProps()
//        }
//        // transfer props to the current camera
//        gameCamera?.transferProps()
//
//        interactionManager.updateAll(cameraInfo: cameraInfo)
//        lastCameraInfo = cameraInfo
//    }

    // MARK: - inbound from network
//    private func process(command: GameCommand) {
//        os_signpost(.begin, log: .render_loop, name: .process_command, signpostID: .render_loop,
//                    "Action : %s", command.action.description)
//        defer { os_signpost(.end, log: .render_loop, name: .process_command, signpostID: .render_loop,
//                            "Action : %s", command.action.description) }
//
//        switch command.action {
//        case .gameAction(let gameAction):
//            if case let .physics(physicsData) = gameAction {
//                physicsSyncData.receive(packet: physicsData)
//            } else {
//                guard let player = command.player else { return }
//                interactionManager.handle(gameAction: gameAction, from: player)
//            }
//        case .boardSetup(let boardAction):
//            if let player = command.player {
//                delegate?.manager(self, received: boardAction, from: player)
//            }
//        case .startGameMusic(let timeData):
//            // Start music at the correct place.
//            if let player = command.player {
//                handleStartGameMusic(timeData, from: player)
//            }
//        }
//    }
    
    // MARK: update
    // Called from rendering loop once per frame
    /// - Tag: GameManager-update
//    func update(timeDelta: TimeInterval) {
//        processCommandQueue()
//        processTouches()
//        syncPhysics()
//
//
//    }



//    private func processCommandQueue() {
//        // retrieving the command should happen with the lock held, but executing
//        // it should be outside the lock.
//        // inner function lets us take advantage of the defer keyword
//        // for lock management.
//        func nextCommand() -> GameCommand? {
//            commandsLock.lock(); defer { commandsLock.unlock() }
//            if gameCommands.isEmpty {
//                return nil
//            } else {
//                return gameCommands.removeFirst()
//            }
//        }
//
//        while let command = nextCommand() {
//            process(command: command)
//        }
//    }
//
//    private func processTouches() {
//        func nextTouch() -> TouchEvent? {
//            touchEventsLock.lock(); defer { touchEventsLock.unlock() }
//            if touchEvents.isEmpty {
//                return nil
//            } else {
//                return touchEvents.removeFirst()
//            }
//        }
//
//        while let touch = nextTouch() {
//            process(touch)
//        }
//    }

//    private func process(_ touch: TouchEvent) {
//        interactionManager.handleTouch(touch.type, camera: touch.camera)
//    }

//    func queueAction(gameAction: GameAction) {
//        commandsLock.lock(); defer { commandsLock.unlock() }
//        gameCommands.append(GameCommand(player: currentPlayer, action: .gameAction(gameAction)))
//    }

   
    
    // Configures the node from the level to be placed on the provided board.
    func addLevel(to node: SCNNode, gameBoard: GameBoard) {
        self.gameBoard = gameBoard
        

        
        // Initialize table box object
//        createTableTopOcclusionBox(level: levelNode)

        updateRenderTransform()
        

    }
    

    
    // call this if the level moves from AR changes or user moving/scaling it
    func updateRenderTransform() {
        guard let gameBoard = self.gameBoard else { return }
        
        // Scale level to normalized scale (1 unit wide) for rendering
//        let levelNodeTransform = float4x4(scale: level.normalizedScale)
//        renderToSimulationTransform = levelNodeTransform.inverse * gameBoard.simdWorldTransform.inverse
    }

    // Initializes all the objects and interactions for the game, and prepares
    // to process user input.
//    func start() {
//        // Now we initialize all the game objects and interactions for the game.
//
//        // reset the index that we assign to GameObjects.
//        // test to make sure no GameObjects are built prior
//        // also be careful that the server increments the counter for new nodes
//        GameObject.resetIndexCounter()
//        categories = [String: [GameObject]] ()
//
//        initializeGameObjectPool()
//
//        initializeLevel()
//        initBehaviors()
//
//        // Initialize interactions that add objects to the level
//        initializeInteractions()
//
//        physicsSyncData.delegate = self
//
//        // Start advertising game
//        if let session = session, session.isServer {
//            session.startAdvertising()
//        }
//
//        delegate?.managerDidStartGame(self)
//
//        startGameMusicEverywhere()
//
//        isInitialized = true
//    }


    


    // MARK: - Table Occlusion

    // Create an opaque object representing the table used to occlude falling objects
//    private func createTableTopOcclusionBox(level: SCNNode) {
//        guard let tableBoxNode = scene.rootNode.childNode(withName: "OcclusionBox", recursively: true) else {
//            fatalError("Table node not found")
//        }
//
//        // make a table object so we can attach audio component to it
//        tableBoxObject = initGameObject(for: tableBoxNode)
//    }

    // MARK: - Initialize Game Functions
    private func teamName(for node: SCNNode) -> String? {
        guard let name = node.name else { return nil }

        // set to A or B, don't set blocks to teamAA, AB, AC
        if name == "_teamA" || name == "_teamB" {
            let teamName = name
            return teamName.isEmpty ? nil : String(teamName)
        }

        return nil
    }

    // Walk all the nodes looking for actual objects.
//    private func enumerateHierarchy(_ node: SCNNode, teamName: String? = nil) {
//        // If the node has no name or a name does not contain
//        // a type identifier, we look at its children.
//        guard let name = node.name, let type = node.typeIdentifier else {
//            let extractedName = self.teamName(for: node)
//            let newTeamName = extractedName ?? teamName
//            for child in node.childNodes {
//                enumerateHierarchy(child, teamName: newTeamName)
//            }
//            return
//        }
//
//        configure(node: node, name: name, type: type, team: teamName)
//    }


    


//    private func postUpdateHierarchy(_ node: SCNNode) {
//        if let nameRestore = node.value(forKey: "nameRestore") as? String {
//            node.name = nameRestore
//        }
//
//        for child in node.childNodes {
//            postUpdateHierarchy(child)
//        }
//    }





//    private func initializeInteractions() {
//        // Grab Interaction
//        let grabInteraction = GrabInteraction(delegate: self)
//        interactionManager.addInteraction(grabInteraction)
//
//        // Highlight Interaction
//        let highlightInteraction = HighlightInteraction(delegate: self)
//        highlightInteraction.grabInteraction = grabInteraction
//        highlightInteraction.sfxCoordinator = sfxCoordinator
//        interactionManager.addInteraction(highlightInteraction)
//
//        // Catapult Interaction
//        let catapultInteraction = CatapultInteraction(delegate: self)
//        catapultInteraction.grabInteraction = grabInteraction
//        interactionManager.addInteraction(catapultInteraction)
//
//        // Fill Catapult Interaction with catapults
//        guard !catapults.isEmpty else { fatalError("Catapult not initialized") }
//        for catapult in catapults {
//            catapultInteraction.addCatapult(catapult)
//        }
//
//        // Catapult Disable Interaction
//        interactionManager.addInteraction(CatapultDisableInteraction(delegate: self))
//
//        // Vortex
//        let vortex = VortexInteraction(delegate: self)
//        vortex.vortexActivationDelegate = catapultInteraction
//        vortex.sfxCoordinator = sfxCoordinator
//        vortex.musicCoordinator = musicCoordinator
//        interactionManager.addInteraction(vortex)
//
//        // Lever
//        let lever = LeverInteraction(delegate: self)
//        var switches = [GameObject]()
//        if let processedSwitches = categories["reset"] {
//            switches = processedSwitches
//        }
//        lever.setup(resetSwitches: switches, interactionToActivate: vortex)
//        lever.sfxCoordinator = sfxCoordinator
//        interactionManager.addInteraction(lever)
//
//        // Victory
//        interactionManager.addInteraction(VictoryInteraction(delegate: self))
//    }
//
//    // MARK: - Physics scaling
//    func copySimulationCamera() {
//        // copy the POV camera to minimize the need to lock, this is right after ARKit updates it in
//        // the render thread, and before we scale the actual POV camera for rendering
//        pointOfViewSimulation.simdWorldTransform = pointOfView.simdWorldTransform
//    }
//
//    func scaleCameraToRender() {
//        pointOfView.simdWorldTransform = renderToSimulationTransform * pointOfView.simdWorldTransform
//    }
//
//    func scaleCameraToSimulation() {
//        pointOfView.simdWorldTransform = pointOfViewSimulation.simdWorldTransform
//    }
//
//    func renderSpacePositionToSimulationSpace(pos: float3) -> float3 {
//        return (renderToSimulationTransform * float4(pos, 1.0)).xyz
//    }
//
//    func renderSpaceTransformToSimulationSpace(transform: float4x4) -> float4x4 {
//        return renderToSimulationTransform * transform
//    }
//
//    func simulationSpacePositionToRenderSpace(pos: float3) -> float3 {
//        return (renderToSimulationTransform.inverse * float4(pos, 1.0)).xyz
//    }
//
//    func initGameObject(for node: SCNNode) -> GameObject {
//        let gameObject = GameObject(node: node, index: nil, gamedefs: gamedefs, alive: true, server: isServer)
//
//        gameObjects.insert(gameObject)
//        setupAudioComponent(for: gameObject)
//        return gameObject
//    }
//
//
//    func didBeginContact(nodeA: SCNNode, nodeB: SCNNode, pos: float3, impulse: CGFloat) {
//        interactionManager.didCollision(nodeA: nodeA, nodeB: nodeB, pos: pos, impulse: impulse)
//    }
//
//




}


