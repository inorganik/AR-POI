//
//  CustomView.swift
//  AR-POI
//
//  Created by Jamie Perkins on 8/24/17.
//  Copyright © 2017 Inorganik Produce, Inc. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Pass through view

class PassThroughView: UIView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in subviews {
            if !subview.isHidden && subview.alpha > 0 && subview.isUserInteractionEnabled && subview.point(inside: convert(point, to: subview), with: event) {
                return true // child is eligible
            }
        }
        return false // child not eligible, forward touch
    }
}
