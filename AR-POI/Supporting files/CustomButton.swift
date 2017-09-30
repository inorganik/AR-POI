//
//  CustomButton.swift
//  AR-POI
//
//  Created by Jamie Perkins on 9/30/17.
//  Copyright © 2017 Inorganik Produce, Inc. All rights reserved.
//

import Foundation
import UIKit

enum CustomButtonType: Int {
    case refreshButton
}

class CustomButton: UIButton {
    
    var type: CustomButtonType?
    var color: UIColor?
    
    override func draw(_ rect: CGRect) {
        
        self.titleLabel?.text = ""
        
        switch type! {
        case .refreshButton:
            ARPOIUI.drawIconRefresh(frame: rect, color: color ?? .white, down: self.isHighlighted)
            return
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            super.isHighlighted = isHighlighted
            self.setNeedsDisplay()
        }
    }
}

