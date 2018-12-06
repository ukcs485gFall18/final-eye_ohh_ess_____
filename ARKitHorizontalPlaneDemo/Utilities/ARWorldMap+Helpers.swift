/*
 //  Created by Karthik on 11/30/18.
 //  Copyright © 2018 eye_Ohh_ess. All rights reserved.
 //

Abstract:
Convenience extension for screenshots in ARWorldMap.
*/

import ARKit

extension ARWorldMap {
    var boardAnchor: BoardAnchor? {
        return anchors.compactMap { $0 as? BoardAnchor }.first
    }
    
    var keyPositionAnchors: [KeyPositionAnchor] {
        return anchors.compactMap { $0 as? KeyPositionAnchor }
    }
}
