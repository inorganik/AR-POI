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
    var annotations = [[String: Any]]()
    
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
    
    // MARK: - Items
    
    func getAndDisplayItemsAroundLocation(_ location: CLLocation, completion: @escaping () -> Void) {
        
        let loader = PlaceLoader()
        loader.getItemsFor(location: location) { (resultItems, errMsg) in
            if let err = errMsg {
                self.appDelegate.alertWithTitle("Error", message: err)
                completion()
            }
            else if let items = resultItems {
                let originTransform = matrix_identity_float4x4
                for item in items {
                    let title = item["title"] as! String
                    let itemLoc = item["location"] as! CLLocation
                    let distance: Double = location.distance(from: itemLoc)
                    let distanceString = loader.metersToRecognizableString(meters: distance)
                    
                    let translationMatrix = MatrixHelper.translate(x: 0, y: 0, z: 5) // TODO: calculate depth based on distance
                    let bearing = MatrixHelper.bearingBetween(startLocation: location, endLocation: itemLoc)
                    let rotationMatrix = MatrixHelper.rotateMatrixAroundY(degrees: bearing * -1, matrix: matrix_identity_float4x4)
                    let transformMatrix = simd_mul(rotationMatrix, translationMatrix)
                    let transform = simd_mul(originTransform, transformMatrix)
                    
                    let anchor = ARAnchor(transform: transform)
                    print("add anchor for title: \(title) and id \(anchor.identifier), bearing: \(bearing)˚, distance: \(distanceString)")
                    self.sceneView.session.add(anchor: anchor)
                }
                // add 0 degrees north anchor for testing
                let translationMatrix = MatrixHelper.translate(x: 0, y: 0, z: 2)
                let anchor = ARAnchor(transform: translationMatrix)
                self.sceneView.session.add(anchor: anchor)
                
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
        print("view for anchor with id: \(anchor.identifier)")
        let labelNode = SKLabelNode(text: "🏡 Home")
        labelNode.horizontalAlignmentMode = .center
        labelNode.verticalAlignmentMode = .center
        return labelNode;
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


