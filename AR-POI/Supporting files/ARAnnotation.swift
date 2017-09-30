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
        super.init(frame: frame)
        self.identifier = identifier
        self.title = title
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
                ARPOIUI.drawTooltipDark(frame: rect, distanceText: distText, distUnitsText: distUnitsText)
                return
            default:
                ARPOIUI.drawTooltipLight(frame: rect, color: accentColor, distanceText: distText, distUnitsText: distUnitsText)
            }
        }
        else {
            print("error drawing AR annotation: view rect is 0")
        }
    }
    
    func validateAndSetLocation(location: CLLocation) -> Bool {
        guard CLLocationCoordinate2DIsValid(location.coordinate) else { return false }
        self.location = location
        return true
    }
    
    func getTooltipImage() -> UIImage {
        
        /* 	title label - a lot of setup to
            make it fit and look as nice as
 			possible in the tooltip */
        var labelText = title
        let charCount = labelText.characters.count
        if charCount > 70 {
            let strIndex = labelText.index(labelText.startIndex, offsetBy: 70)
            labelText = String(labelText[..<strIndex])
        }
        var fontSize: CGFloat = 23.0
        var numberOfLines: Int = 1
        if charCount > 55 {
            fontSize = 13.0
            numberOfLines = 3
        }
        else if charCount > 40 {
            fontSize = 15.0
            numberOfLines = 3
        }
        else if charCount > 15 {
            fontSize = 17.0
            numberOfLines = 2
        }
        
        let labelMaxWidth: CGFloat = 161
        let labelMinWidth: CGFloat = 99
        let distViewWidth: CGFloat = 59 // added width of distance view
        let labelMargin: CGFloat = 11
        let tooltipBaseHeight: CGFloat = 45
        let tooltipTopMargin: CGFloat = 3 // room for top shadow
        let tooltipBottomMargin: CGFloat = 22 // room for arrow and shadow
        let titleLabel = UILabel(frame: CGRect(x: labelMargin, y:labelMargin + tooltipTopMargin, width:labelMaxWidth, height:tooltipBaseHeight))
        titleLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .medium)
        titleLabel.numberOfLines = numberOfLines
        titleLabel.textAlignment = .center
        titleLabel.text = labelText
        switch type {
        case .darkTooltip:
            titleLabel.textColor = .white
        default:
            titleLabel.textColor = .black
        }
        var labelSize = titleLabel.sizeThatFits(CGSize(width: labelMaxWidth, height: CGFloat.infinity))
        labelSize.width = max(labelMinWidth, labelSize.width)
        var labelTopMargin = labelMargin
        if titleLabel.numberOfLines == 1 {
            labelTopMargin = (tooltipBaseHeight - labelSize.height) / 2
        }
        titleLabel.frame = CGRect(x: labelMargin, y:labelTopMargin, width:labelSize.width, height:labelSize.height)
        let tooltipWidth = labelSize.width + labelMargin * 2 + distViewWidth
        let tooltipHeight = labelSize.height + labelTopMargin * 2 + tooltipBottomMargin
        let tooltipSize = CGSize(width: tooltipWidth, height: tooltipHeight)
        self.addSubview(titleLabel)
        self.frame = CGRect(origin: CGPoint.zero, size: tooltipSize)
        
        // get image from graphics context
        UIGraphicsBeginImageContextWithOptions(tooltipSize, false, 0.0)
        let context = UIGraphicsGetCurrentContext()!
        self.layer.render(in: context)
        let composite: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
		return composite
    }
}


