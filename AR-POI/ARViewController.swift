//
//  ARViewController.swift
//  AR-POI
//
//  Created by Jamie Perkins on 9/26/17.
//  Copyright © 2017 Inorganik Produce, Inc. All rights reserved.
//

import UIKit
import SpriteKit
import ARKit
import CoreLocation

class ARViewController: UIViewController, ARSKViewDelegate {
    
    @IBOutlet var sceneView: ARSKView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var annotations = [ARAnnotation]()
    
    // set anchor distances (m) for nearest and farthest
    let anchorNearest: Float = 1
    let anchorFarthest: Float = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and node count
        sceneView.showsFPS = true
        sceneView.showsNodeCount = true
        
        // Load the SKScene from 'Scene.sks'
        if let scene = SKScene(fileNamed: "Scene") {
            sceneView.presentScene(scene)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    func activateARView() {
        let config = ARWorldTrackingConfiguration()
        config.worldAlignment = .gravityAndHeading
        sceneView.session.run(config)
    }
    
    // MARK: - POIs
    
    func getAndDisplayItemsAroundLocation(_ location: CLLocation, completion: @escaping () -> Void) {
        
        let loader = PlaceLoader()
        let anchorSpread = anchorFarthest - anchorNearest
        loader.getPOIsFor(location: location) { (resultPOIs, errMsg) in
            if let err = errMsg {
                self.appDelegate.alertWithTitle("Error", message: err)
                completion()
            }
            else if let pois = resultPOIs {
                let annotRect = CGRect(x: 0, y: 0, width: 240, height: 73)
                var poiNearest: Double = 0
                var poiFarthest: Double = 0
                // determine nearest and farthest poi
                for poi in pois {
                    let poiLoc = poi["location"] as! CLLocation
                    let distanceMeters: Double = location.distance(from: poiLoc)
                    if distanceMeters > poiFarthest {
                        poiFarthest = distanceMeters
                    }
                    if poiNearest == 0 {
                        poiNearest = distanceMeters
                    }
                    else if distanceMeters < poiNearest {
                        poiNearest = distanceMeters
                    }
                }
                let poiSpread = poiFarthest - poiNearest
                // create annotations
                for poi in pois {
                    // get properties from poi
                    let title = poi["title"] as! String
                    let poiLoc = poi["location"] as! CLLocation
                    let distanceMeters: Double = location.distance(from: poiLoc)
                    let distance = loader.metersToRecognizableString(meters: distanceMeters)
                    // calculate anchor distance from user (size) based on actual distance
                    let anchorDist = (distanceMeters * Double(anchorSpread) / poiSpread) + Double(self.anchorNearest)
                    // transformation matrix for placing poi
                    let origin = MatrixHelper.translate(x: 0, y: 0, z: Float(anchorDist * -1))
                    let bearing = MatrixHelper.bearingBetween(startLocation: location, endLocation: poiLoc)
                    let transform = MatrixHelper.rotateMatrixAroundY(degrees: bearing * -1, matrix: origin)
                    
                    let anchor = ARAnchor(transform: transform)
                    // create an append annotation
                    let annot = ARAnnotation(frame: annotRect, identifier: anchor.identifier, title: title)
                    annot.distanceText = distance.0
                    annot.distanceUnitsText = distance.1
                    let _ = annot.validateAndSetLocation(location: poiLoc) // not used here, but might be useful for handling tap on annotation
                    self.annotations.append(annot)
                    //print("add anchor for title: \(title) and id \(anchor.identifier), bearing: \(bearing)˚, distance: \(anchorDist)")
                    self.sceneView.session.add(anchor: anchor)
                }
                /* add 0 degrees north anchor for testing
                let origin = MatrixHelper.translate(x: 0, y: 0, z: -3)
                let transform = MatrixHelper.rotateMatrixAroundY(degrees: 0, matrix: origin)
                let anchor = ARAnchor(transform: transform)
                let annot = ARAnnotation(frame: annotRect, identifier: anchor.identifier, title: "north")
                self.annotations.append(annot)
                self.sceneView.session.add(anchor: anchor)
                */
                completion()
            }
            else {
                completion()
            }
        }
    }
    
    // MARK: - ARSKViewDelegate
    
    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
        // Create and configure a node for the anchor added to the view's session.
        let annots = annotations.filter {
            $0.identifier! == anchor.identifier
        }
        if annots.count > 0 {
            let annot = annots.first
            let image = annot?.getTooltipImage()
            let tooltip = SKTexture(image: image!)
            let sprite = SKSpriteNode(texture: tooltip)
            sprite.name = "\(anchor.identifier)"
            return sprite
        }
        return nil
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}


