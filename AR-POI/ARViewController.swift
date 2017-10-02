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
    let anchorDistNearest: Float = 1
    let anchorDistFarthest: Float = 4
    // set anchor heights (degrees) for nearest and farthest
    let anchorDegreesNearest: Double = 0
    let anchorDegreesFarthest: Double = 15
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        
        // Show statistics such as fps and node count
        // sceneView.showsFPS = true
        // sceneView.showsNodeCount = true
        
        // Load the SKScene from 'Scene.sks'
        if let scene = SKScene(fileNamed: "Scene") {
            sceneView.presentScene(scene)
        }
        // listen for notif to remove nodes
        NotificationCenter.default.addObserver(self, selector: #selector(removeNodes), name: Notification.Name("shouldRemoveNodes"), object: nil)
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
    
    func getAndDisplayItemsAroundLocation(_ location: CLLocation, completion: @escaping (Int) -> Void) {
        
        let searchTerm = "burgers"
        let loader = PlaceLoader()
        
        let anchorDistSpread = anchorDistFarthest - anchorDistNearest
        let anchorHeightSpread = anchorDegreesFarthest - anchorDegreesNearest
        
        //loader.getStaticPOIsFor(location: location) { (resultPOIs, errMsg) in
        loader.requestPOIsWithGoogleSearch(term: searchTerm, location: location) { (resultPOIs, errMsg) in
            if let err = errMsg {
                self.appDelegate.alertWithTitle("Error", message: err)
                completion(0)
            }
            else if let pois = resultPOIs {
                var poiNearest: Double = 0
                var poiFarthest: Double = 0
                // determine nearest and farthest poi
                for poi in pois {
                    let geometry = poi["geometry"] as? [String: Any]
                    let poiLoc = loader.getLocationFrom(dict: geometry!)!
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
                let annotRect = CGRect(x: 0, y: 0, width: 240, height: 73)
                let poiSpread = poiFarthest - poiNearest
                // create annotations
                for poi in pois {
                    // get properties from poi
                    let title = poi["name"] as! String
                    let geometry = poi["geometry"] as? [String: Any]
                    let poiLoc = loader.getLocationFrom(dict: geometry!)!
                    let distanceMeters: Double = location.distance(from: poiLoc)
                    let distance = loader.metersToRecognizableString(meters: distanceMeters)
                    let bearing = MatrixHelper.bearingBetween(startLocation: location, endLocation: poiLoc)
                    // calculate anchor distance and height from user based on actual distance
                    let anchorDist = (distanceMeters * Double(anchorDistSpread) / poiSpread) + Double(self.anchorDistNearest)
                    let anchorHeightDegrees = (distanceMeters * anchorHeightSpread / poiSpread) + self.anchorDegreesNearest
                    let angleMultiplier: Float = (bearing > 270 || bearing < 90) ? 1.0 : -1.0
                    let angleAdjust = Float(anchorHeightDegrees) * angleMultiplier
                    // transformation matrix for placing poi
                    let origin = MatrixHelper.translate(x: 0, y: 0, z: Float(anchorDist * -1))
                    let bearingTransform = MatrixHelper.rotateMatrixAroundY(degrees: bearing * -1, matrix: origin)
                    let transform = MatrixHelper.translateMatrixFromHorizon(degrees: angleAdjust, matrix: bearingTransform)
                    // anchor
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
                completion(pois.count)
            }
            else {
                completion(0)
            }
        }
    }
    
    @objc func removeNodes() {
        sceneView.scene?.enumerateChildNodes(withName: "poi", using: { (node, stop) in
            node.removeFromParent()
        })
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
            sprite.name = "poi"
            return sprite
        }
        return nil
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        if case .limited(let reason) = camera.trackingState {
            print("tracking state is limited: \(reason)")
        }
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


