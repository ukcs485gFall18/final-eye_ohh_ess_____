//
//  Configuration.swift
//  ARKitHorizontalPlaneDemo
//
//  Created by Dagmawi Nadew-Assefa on 10/29/18.
//  Copyright © 2018 eye_Ohh_ess. All rights reserved.
//

import UIKit
import ARKit

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


enum PreviewBox {
    static let height: CGFloat   = 0.1
    static let width:  CGFloat   = 0.1
    static let length: CGFloat   = 0.1
    static let radius: CGFloat   = 0
}

enum DefaultPoint {
    static let xLocation = 0.0
    static let yLocation = 0.0
}

enum Gesture {
    static let defaultScale: CGFloat = 1
}
