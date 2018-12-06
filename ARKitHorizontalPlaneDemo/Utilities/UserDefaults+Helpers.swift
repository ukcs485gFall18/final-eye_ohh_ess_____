/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Convenience extension for type safe UserDefaults access.
*/

import Foundation
import MultipeerConnectivity

struct UserDefaultsKeys {
    
    // settings
    static let antialiasingMode = "AntialiasingMode"
    static let peerID = "PeerIDDefaultsKey"

    static let hasOnboarded = "HasOnboarded"
    static let boardLocatingMode = "BoardLocatingMode"
    static let gameRoomMode = "GameRoomMode"
    static let autoFocus = "AutoFocus"

    static let showReset = "ShowReset"
}

extension UserDefaults {

    enum BoardLocatingMode: Int {
        case worldMap = 0 // default
        // slot 1 previously used; leave empty so that on update,
        // worldMap is used insead.
        case manual = 2
    }

    static let applicationDefaults: [String: Any] = [

        UserDefaultsKeys.antialiasingMode: true,
        UserDefaultsKeys.gameRoomMode: false,
        UserDefaultsKeys.autoFocus: true,
        UserDefaultsKeys.showReset: false,
     
        ]

    var myself: Player {
        get {
            if let data = data(forKey: UserDefaultsKeys.peerID),
                let unarchived = try? NSKeyedUnarchiver.unarchivedObject(ofClass: MCPeerID.self, from: data),
                let peerID = unarchived {
                return Player(peerID: peerID)
            }
            // if no playerID was previously selected, create and cache a new one.
            let player = Player(username: UIDevice.current.name)
            let newData = try? NSKeyedArchiver.archivedData(withRootObject: player.peerID, requiringSecureCoding: true)
            set(newData, forKey: UserDefaultsKeys.peerID)
            return player
        }
        set {
            let data = try? NSKeyedArchiver.archivedData(withRootObject: newValue.peerID, requiringSecureCoding: true)
            set(data, forKey: UserDefaultsKeys.peerID)
        }
    }

    
    // this may need to be integer for 0, 2, 4x
    var antialiasingMode: Bool {
        get { return bool(forKey: UserDefaultsKeys.antialiasingMode) }
        set { set(newValue, forKey: UserDefaultsKeys.antialiasingMode) }
    }

    var hasOnboarded: Bool {
        get { return bool(forKey: UserDefaultsKeys.hasOnboarded) }
        set { set(newValue, forKey: UserDefaultsKeys.hasOnboarded) }
    }

    var boardLocatingMode: BoardLocatingMode {
        get { return BoardLocatingMode(rawValue: integer(forKey: UserDefaultsKeys.boardLocatingMode)) ?? .worldMap }
        set { set(newValue.rawValue, forKey: UserDefaultsKeys.boardLocatingMode) }
    }

    var gameRoomMode: Bool {
        get { return bool(forKey: UserDefaultsKeys.gameRoomMode) }
        set { set(newValue, forKey: UserDefaultsKeys.gameRoomMode) }
    }
    
    var showResetLever: Bool {
        get { return bool(forKey: UserDefaultsKeys.showReset) }
        set { set(newValue, forKey: UserDefaultsKeys.showReset) }
    }
    
    var autoFocus: Bool {
        get { return bool(forKey: UserDefaultsKeys.autoFocus) }
        set { set(newValue, forKey: UserDefaultsKeys.autoFocus) }
    }
    
}
