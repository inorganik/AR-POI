//
//  PlaceLoader.swift
//  AR-POI
//
//  Created by Jamie Perkins on 9/26/17.
//  Copyright © 2017 Inorganik Produce, Inc. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

struct PlaceLoader {
    
    // requests POIs around user's location
    func getPOIsFor(location: CLLocation, completion: @escaping (_ items:[[String: Any]]?, _ errorMsg:String?) -> Void) {
        
        var returnPOIs = [[String: Any]]()
        
        let home = [
            "title": "Home",
            "location": CLLocation(latitude: 39.62578, longitude: -105.133526)
            ] as [String: Any]
        returnPOIs.append(home)
        
        let littleton = [
            "title": "Littleton",
            "location": CLLocation(latitude: 39.61402, longitude: -105.0178)
            ] as [String: Any]
        returnPOIs.append(littleton)
        
        let work = [
            "title": "Work", // 39.75053, -104.99957
            "location": CLLocation(latitude: 39.75053, longitude: -104.99957)
            ] as [String: Any]
        returnPOIs.append(work)
        
        let boulder = [
            "title": "Boulder", // 40.01762, -105.28027
            "location": CLLocation(latitude: 40.01762, longitude: -105.25027)
            ] as [String: Any]
        returnPOIs.append(boulder)
        
        let chatfield = [
            "title": "Chatfield", // 39.5476, -105.07084
            "location": CLLocation(latitude: 39.5476, longitude: -105.07084)
            ] as [String: Any]
        returnPOIs.append(chatfield)
        
        if returnPOIs.count > 0 {
            completion(returnPOIs, nil)
        }
        else {
            completion(nil, "no POIs")
        }
    }
    
    // turn meters into relatable distance
    func metersToRecognizableString(meters: Double) -> (String, String) {
        
        let METERS_TO_FEET: Double = 3.2808399
        let FEET_TO_MILES: Double = 5280
        let FOOTBALL_FIELD: Double = 300
        
        let distance: Double = meters * METERS_TO_FEET;
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        if (distance < FOOTBALL_FIELD) {
            formatter.maximumFractionDigits = 0
            let formatted = formatter.string(from: NSNumber(value:distance));
            return (String(format: "%@", formatted!), "feet")
        }
        else {
            formatter.maximumFractionDigits = 1
            let miles = distance / FEET_TO_MILES
            let formatted = formatter.string(from: NSNumber(value:miles))
            return (String(format: "%@", formatted!), "miles")
        }
    }
}

