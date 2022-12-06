//
//  Place.swift
//  PlaceLookupDemo
//
//  Created by Richard Isaacs on 21.11.22.
//

import Foundation
import MapKit


class TestClass:  ObservableObject {
    static func p()
    {
        print ("ppppp")
    }
}


struct Place: Identifiable {
    let id = UUID().uuidString
    private var mapItem: MKMapItem
    
    init (mapItem: MKMapItem) {
        print ("----- \(mapItem)  ")
        //TestClass.p()
        self.mapItem = mapItem
    }
    
    var name: String {
        self.mapItem.name ?? ""
    }
    
    var address: String {
        let placemark = self.mapItem.placemark
        var cityAndState = ""
        var address = ""
        
        cityAndState = placemark.locality ?? ""
        if let state = placemark.administrativeArea {
            // Show either state or city, stste
            cityAndState = cityAndState.isEmpty ? state : "\(cityAndState), \(state)"
        }
        
        address = placemark.subThoroughfare ?? "" // address nr
        if let street = placemark.thoroughfare {
            // just show street unless there is a street nr, then add space + street
            
            address = address.isEmpty ? street : "\(address) \(street)"
        }
        
        if address.trimmingCharacters(in: .whitespaces).isEmpty && !cityAndState.isEmpty {
            // No address?m then just cityAnState with no spaces
            address = cityAndState
        } else {
            // no cityAndState, then just address, otherwise address, cityAndState
            address = cityAndState.isEmpty ? address : "\(address), \(cityAndState)"
        }
        
        return address
    } // address
    
    var latitude : CLLocationDegrees {
        self.mapItem.placemark.coordinate.latitude
    }
    
    var longitude : CLLocationDegrees {
        self.mapItem.placemark.coordinate.longitude
    }
}
