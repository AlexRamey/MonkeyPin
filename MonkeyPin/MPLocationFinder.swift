//
//  MPLocationFinder.swift
//  MonkeyPin
//
//  Created by Alex Ramey on 4/18/16.
//  Copyright © 2016 Alex Ramey. All rights reserved.
//

import CoreLocation

protocol MPLocationFinderDelegate{
    func locationFinder(locationFinder: MPLocationFinder, didFindLocation location:CLLocation)
    func locationFinderDidFail(locationFinder: MPLocationFinder)
}

class MPLocationFinder: NSObject, CLLocationManagerDelegate {
    var locationManager:CLLocationManager? = nil
    var callback:MPLocationFinderDelegate? = nil
    
    // require a callback to be specified at initialization
    init(delegate:MPLocationFinderDelegate) {
        
        // keep a strong reference to the callback
        self.callback = delegate
        
        // superclass initialization
        super.init()
        
        self.locationManager = CLLocationManager()
        
        if let locationManager = self.locationManager{
            // Let's get the best accuracy since we're only using this to grab
            // one location point
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.delegate = self
            
            let status:CLAuthorizationStatus = CLLocationManager.authorizationStatus()
            if (status == CLAuthorizationStatus.NotDetermined){
                locationManager.requestWhenInUseAuthorization()
            }else if (status == CLAuthorizationStatus.AuthorizedWhenInUse){
                locationManager.startUpdatingLocation()
            }
        }else{
            // report back a failure and release the delegate object
            self.callback?.locationFinderDidFail(self)
            self.callback = nil
        }
    }
    
    deinit {
        // tear down the location manager (if necessary) by first telling it to stop updating location
        // and then notifying it that it's delegate (self) is gone
        if let locationManager = self.locationManager{
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
        }
    }
    
    
    // MARK - CLLocationManagerDelegate Methods
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // If it's a relatively recent event, turn off updates to save power.
        if let recentLocation = locations.last{
            let timestamp = recentLocation.timestamp
            if (abs(timestamp.timeIntervalSinceNow) < 60.0){
                // We have a CLLocation from within the last mintue!
                // report it to the delegate and then release the delegate object
                self.callback?.locationFinder(self, didFindLocation: recentLocation)
                self.callback = nil
                self.locationManager?.stopUpdatingLocation()
            }
        }
       
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        self.locationManager?.stopUpdatingLocation()
        // report back a failure and release the delegate object
        self.callback?.locationFinderDidFail(self)
        self.callback = nil
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status{
        case .AuthorizedWhenInUse:
            if let locationManager = self.locationManager{
                locationManager.startUpdatingLocation()
            }
        default:
            // report back a failure and release the delegate object
            self.callback?.locationFinderDidFail(self)
            self.callback = nil
        }
    }
}
