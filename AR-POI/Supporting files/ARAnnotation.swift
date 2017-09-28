//
//  ARAnnotation.swift
//  AR-POI
//
//  Created by Jamie Perkins on 9/27/17.
//  Copyright © 2017 Inorganik Produce, Inc. All rights reserved.
//

import UIKit
import CoreLocation


open class ARAnnotation: NSObject {

    open var identifier: String?
    open var title: String?
    open var distance: String?
    open var location: CLLocation

    public init?(identifier: String?, title: String?, location: CLLocation) {
        guard CLLocationCoordinate2DIsValid(location.coordinate) else { return nil }
        
        self.identifier = identifier
        self.title = title
        self.location = location
    }
    
    // Validates location.coordinate and sets it.
    open func validateAndSetLocation(location: CLLocation) -> Bool {
        guard CLLocationCoordinate2DIsValid(location.coordinate) else { return false }
        
        self.location = location
        return true
    }
}

