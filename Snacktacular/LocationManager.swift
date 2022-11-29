//
//  LocationManager.swift
//  PlaceLookupDemo
//
//  Created by Richard Isaacs on 18.11.22.
//

import Foundation
import MapKit

@MainActor
class LocationManager: NSObject, ObservableObject {
    
    @Published var location: CLLocation?
    @Published var region = MKCoordinateRegion()
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation() // Remember to update info.plist
        locationManager.delegate = self
        
        if locationManager.isAuthorizedForWidgetUpdates {
            print ("updates")
        } else {
            print ("no updates")
        }
        
        if CLLocationManager.isRangingAvailable() {
            print ("isRangingAvailable")
        } else {
            print ("no isRangingAvailable")
        }
        
        //CLLocationManager.significantLocationChangeMonitoringAvailable()
        //let a = LocationManager.description()
        
    }
} // LocationManager

// Called by IOS location manager, will be updated automatically
// My locagtion 48deg12'48" 15deg37'28"
// 48.21351577643776, 15.627804606894154

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
           
        print ("===== \(location)  = \(locations.count)  ")
        
        self.location = location
        
        //let a = location.altitude
        
        self.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
        
    }
    

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print ("##### \(error.localizedDescription)")
    }
    
}
