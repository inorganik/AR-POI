//
//  ContainerViewController.swift
//  AR-POI
//
//  Created by Jamie Perkins on 9/26/17.
//  Copyright © 2017 Inorganik Produce, Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import CoreMotion

class ContainerViewController: UIViewController {
    
    @IBOutlet var headingLabel: UILabel!
    @IBOutlet var countLabel: UILabel!
    @IBOutlet var refreshButton: CustomButton!
    
    var arView: ARViewController!
    var showsDebuggingLabels: Bool = false
    // location
    fileprivate let locationManager = CLLocationManager()
    var requestedItems: Bool = false
    // motion
    let debugHeading: Bool = false // make true to track heading
    let mmgr = CMMotionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let screenSize = UIScreen.main.bounds.size
        view.backgroundColor = .black
        
        headingLabel.isHidden = !debugHeading
        countLabel.isHidden = true
        refreshButton.type = .refreshButton
        
        // add AR subview
        arView = self.storyboard?.instantiateViewController(withIdentifier: "arView") as! ARViewController
        self.addChildViewController(arView)
        arView.view.frame = CGRect(x:0, y:0, width:screenSize.width, height:screenSize.height)
        self.view.insertSubview(arView.view, at: 0)
        arView.didMove(toParentViewController: self)
        addConstraintsFor(arView.view, width: screenSize.width, idPrefix: "ar")
        
        // location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
		
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("request when in use auth")
        locationManager.requestWhenInUseAuthorization()
        if debugHeading == true {
        	startMotionTracking()
        }
    }
    
    func addConstraintsFor(_ nestedView: UIView, width: CGFloat, idPrefix: String) {
        
        nestedView.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = NSLayoutConstraint(item: nestedView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0)
        topConstraint.identifier = idPrefix + "TopConstraint"
        self.view.addConstraint(topConstraint)
        let bottomConstraint = NSLayoutConstraint(item: nestedView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)
        bottomConstraint.identifier = idPrefix + "BottomConstraint"
        self.view.addConstraint(bottomConstraint)
        let leftConstraint = NSLayoutConstraint(item: nestedView, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1, constant: 0)
        leftConstraint.identifier = idPrefix + "LeftConstraint"
        self.view.addConstraint(leftConstraint)
        let rightConstraint = NSLayoutConstraint(item: nestedView, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1, constant: 0)
        rightConstraint.identifier = idPrefix + "RightConstraint"
        self.view.addConstraint(rightConstraint)
    }
    
    @IBAction func refreshButtonTapped(_ sender: Any) {
        
        let notifName = Notification.Name("shouldRemoveNodes")
        NotificationCenter.default.post(name: notifName, object: nil)
        
        self.countLabel.text = "Searching…"
        requestedItems = false
        locationManager.startUpdatingLocation()
    }
    
    func showCount(_ count: Int) {
        self.countLabel.isHidden = false
        let placesPlural = (count == 1) ? "place" : "places"
        self.countLabel.text = "\(count) \(placesPlural) found"
    }
    
    // MARK: - motion
    
    // motion tracking allows us to get the heading for debugging (iOS 11+)
    func startMotionTracking() {
        mmgr.stopDeviceMotionUpdates()
        mmgr.deviceMotionUpdateInterval = 0.5
        mmgr.showsDeviceMovementDisplay = true
        mmgr.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: .main, withHandler: { (motionData: CMDeviceMotion?, error: Error?) in
            if let err = error {
                print("device motion update error", err.localizedDescription)
            }
            if let motion = motionData {
                self.headingLabel.text = "heading: \(self.correctHeading(motion.heading, for: UIDevice.current.orientation))"
            }
        })
    }
    
    // this corrects the heading for when device is in landscape
    func correctHeading(_ heading: Double, for orientation: UIDeviceOrientation) -> Double {
        var orientationCorrection: Double = 0
        if orientation == .landscapeRight { // home button left
            orientationCorrection = -90
        }
        else if orientation == .landscapeLeft { // home button right
            orientationCorrection = 90
        }
        var result = heading + orientationCorrection
        if result > 360 {
            result = result - 360
        }
        else if result < 0 {
            result = result + 360
        }
        return result
    }
    
    // MARK: - spinner
    
    // show spinner in view
    func startSpinnerInView(view: UIView) -> UIView {
        // box containing the spinner
        let loadingContainer = UIView.init(frame:CGRect(x:0, y:0, width:100, height:100))
        loadingContainer.center = CGPoint(x:view.frame.size.width / 2, y:(view.frame.size.height / 2))
        loadingContainer.backgroundColor = UIColor.black
        loadingContainer.alpha = 0.75
        loadingContainer.clipsToBounds = true
        loadingContainer.layer.cornerRadius = 10
        
        // create the UIActivityIndicator
        let spinner: UIActivityIndicatorView = UIActivityIndicatorView()
        spinner.frame = CGRect(x:0, y:0, width:40, height:40)
        spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        spinner.center = CGPoint(x:loadingContainer.frame.size.width / 2, y:(loadingContainer.frame.size.height) / 2);
        
        // add subviews
        loadingContainer.addSubview(spinner)
        view.addSubview(loadingContainer)
        spinner.startAnimating()
        
        // make the loading box small, then animate to size
        loadingContainer.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.3, animations: {
            loadingContainer.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
        
        return loadingContainer
    }
    
    // get rid of the spinner
    func stopSpinner(spinnerView: UIView) {
        UIView.animate(withDuration: 0.2, animations: {
            spinnerView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            spinnerView.alpha = 0
        }) { (Bool) in
            spinnerView.removeFromSuperview()
        }
    }
}

extension ContainerViewController: CLLocationManagerDelegate {
    
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true
    }
    
    // get location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if locations.count > 0, let loc = locations.last {
            //print("Accuracy: \(String(describing: location.horizontalAccuracy))")
            print("location: \(loc.coordinate.latitude), \(loc.coordinate.longitude)")
            
            if loc.horizontalAccuracy < 100 {
                manager.stopUpdatingLocation()
                
                if !requestedItems {
                    
                    let spinner = self.startSpinnerInView(view: self.view)
                    self.arView.getAndDisplayItemsAroundLocation(loc, completion: { (count) in
                        self.stopSpinner(spinnerView: spinner)
                        self.showCount(count)
                    })
                    requestedItems = true
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

        switch status {
        case .authorizedWhenInUse,
             .authorizedAlways:
            print("location granted")
            locationManager.startUpdatingLocation()
            self.arView.activateARView()
            break
        case .denied,
             .restricted:
            let noLocationAlert = UIAlertController(
                title: "Location Access Disabled",
                message: "In order to see items around you, please open settings and grant location access.",
                preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            noLocationAlert.addAction(cancelAction)
            let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
                if let url = URL(string:UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            noLocationAlert.addAction(openAction)
            self.present(noLocationAlert, animated: true, completion: nil)
            
            break
        case .notDetermined:
            // since this is checked as soon as location mgr is instantiated, we ingore for now
            print("location not determined")
            break
        }
    }
}
