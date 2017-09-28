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
    
    // requests items around user's location
    func getItemsFor(location: CLLocation, completion: @escaping (_ items:[[String: Any]]?, _ errorMsg:String?) -> Void) {
        //print("got items: \(result as AnyObject)")
        var returnItems = [[String: Any]]()
        
        let home = [
            "title": "Home",
            "location": CLLocation(latitude: 39.62578, longitude: -105.133526)
            ] as [String: Any]
        returnItems.append(home)
        
        let littleton = [
            "title": "Littleton",
            "location": CLLocation(latitude: 39.61402, longitude: -105.0178)
            ] as [String: Any]
        returnItems.append(littleton)
        
        let work = [
            "title": "Work", // 39.75053, -104.99957
            "location": CLLocation(latitude: 39.75053, longitude: -104.99957)
            ] as [String: Any]
        returnItems.append(work)
        
        let boulder = [
            "title": "Boulder", // 40.01762, -105.28027
            "location": CLLocation(latitude: 40.01762, longitude: -105.25027)
            ] as [String: Any]
        returnItems.append(boulder)
        
        let fortCollins = [
            "title": "Fort Collins", // 40.55294, -105.09642
            "location": CLLocation(latitude: 40.55294, longitude: -105.09642)
            ] as [String: Any]
        returnItems.append(fortCollins)
        
        if returnItems.count > 0 {
            completion(returnItems, nil)
        }
        else {
            completion(nil, "no items")
        }
    }
    
    // turn meters into relatable distance
    func metersToRecognizableString(meters: Double) -> String {
        
        let METERS_TO_FEET: Double = 3.2808399
        let FEET_TO_MILES: Double = 5280
        let FOOTBALL_FIELD: Double = 300
        
        let distance: Double = meters * METERS_TO_FEET;
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        if (distance < FOOTBALL_FIELD) {
            formatter.maximumFractionDigits = 0
            let formatted = formatter.string(from: NSNumber(value:distance));
            return String(format: "%@ ft", formatted!)
        }
        else {
            formatter.maximumFractionDigits = 1
            let miles = distance / FEET_TO_MILES
            let formatted = formatter.string(from: NSNumber(value:miles))
            return String(format: "%@ mi", formatted!)
        }
    }
}

