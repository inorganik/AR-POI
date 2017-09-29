//
//  ARAnnotation.swift
//  AR-POI
//
//  Created by Jamie Perkins on 9/27/17.
//  Copyright © 2017 Inorganik Produce, Inc. All rights reserved.
//

import UIKit
import CoreLocation

enum AnnotationStyle: Int {
    case lightTooltip
    case darkTooltip
}

class ARAnnotation: UIView {

    var identifier: UUID?
    var title: String = "Title"
    var distanceText: String?
    var distanceUnitsText: String?
    var location: CLLocation?
    
    var distance: String?
    var accentColor: UIColor = ARPOIUI.locationBlue
    var type: AnnotationStyle = .lightTooltip
    
    init(frame: CGRect, identifier: UUID, title: String) {
        self.identifier = identifier
        self.title = title
        super.init(frame: frame)
        self.backgroundColor = .clear
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        let distText = self.distanceText ?? ""
        let distUnitsText = self.distanceUnitsText ?? ""
        if rect.size.width > 0 {
            switch type {
            case .darkTooltip:
                ARPOIUI.drawTooltipDark(frame: rect, distanceText: distText, distUnitsText: distUnitsText, titleText: title)
                return
            default:
                ARPOIUI.drawTooltipeLight(frame: rect, color: accentColor, distanceText: distText, distUnitsText: distUnitsText, titleText: title)
            }
        }
        else {
            print("error drawing AR annotation: view rect is 0")
        }
    }
    
    // Validates location.coordinate and sets it.
    func validateAndSetLocation(location: CLLocation) -> Bool {
        guard CLLocationCoordinate2DIsValid(location.coordinate) else { return false }
        self.location = location
        return true
    }
    
    func getTooltipImage() -> UIImage {
        // graphics context
        let resultSize = CGSize(width: 240, height: 73)
        UIGraphicsBeginImageContextWithOptions(resultSize, false, 0.0)
        let context = UIGraphicsGetCurrentContext()!
        self.layer.render(in: context)
        let composite: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
		return composite
    }
}


