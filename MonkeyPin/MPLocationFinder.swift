//
//  MPLocationFinder.swift
//  MonkeyPin
//
//  Created by Alex Ramey on 4/18/16.
//  Copyright © 2016 Alex Ramey. All rights reserved.
//

import CoreLocation

protocol MPLocationFinderDelegate: class{
    func locationFinder(locationFinder: MPLocationFinder, didFindLocation location:CLLocation)
    func locationFinderDidFail(locationFinder: MPLocationFinder, isPermissionIssue issue:Bool)
}

class MPLocationFinder: NSObject, CLLocationManagerDelegate {
    var locationManager:CLLocationManager? = nil
    weak var callback:MPLocationFinderDelegate? = nil
    
    static func leaderboardEntryForPlacemark(placemark: CLPlacemark)->String{
        guard let countryCode = placemark.ISOcountryCode else{
            return ""
        }
        
        if (countryCode == "US"){
            if let addressDictionary = placemark.addressDictionary{
                if (addressDictionary.keys.contains("City") && addressDictionary.keys.contains("State")){
                    return (addressDictionary["City"] as! String) + ", " + (addressDictionary["State"] as! String)
                }
            }
            return "United States"
        }else{
            if let countryName = placemark.country{
                return countryName
            }else{
                return countryCode  // for international, just return country code
            }
        }
    }
    
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
        }else{
            // report back a failure
            self.callback?.locationFinderDidFail(self, isPermissionIssue: false)
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
                // report it to the delegate
                self.callback?.locationFinder(self, didFindLocation: recentLocation)
                self.locationManager?.stopUpdatingLocation()
            }
        }
       
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        self.locationManager?.stopUpdatingLocation()
        // report back a failure
        self.callback?.locationFinderDidFail(self, isPermissionIssue: false)
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        // print("\(status.rawValue)")
        switch status{
        case .NotDetermined:
            if let locationManager = self.locationManager{
                // it's up for grabs
                // print("not determined")
                locationManager.requestWhenInUseAuthorization()
            }
        case .AuthorizedWhenInUse:
            if let locationManager = self.locationManager{
                locationManager.startUpdatingLocation()
            }
        default:
            // report back a failure
            self.callback?.locationFinderDidFail(self, isPermissionIssue: true)
        }
    }
}
