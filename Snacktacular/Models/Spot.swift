//
//  Spot.swift
//  Snacktacular
//
//  Created by Richard Isaacs on 17.11.22.
//

import Foundation
import FirebaseFirestoreSwift
import CoreLocation

struct Spot: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    
    var name = ""
    var address = ""
    var latitude = 0.0
    var longitude = 0.0
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    
    var dictionary: [String: Any] {
        return ["name": name, "address": address,
                "latitude": latitude, "longitude": longitude]
    }
    
    
}
