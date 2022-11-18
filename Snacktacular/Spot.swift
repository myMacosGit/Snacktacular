//
//  Spot.swift
//  Snacktacular
//
//  Created by Richard Isaacs on 17.11.22.
//

import Foundation
import FirebaseFirestoreSwift

struct Spot: Identifiable, Codable {
    @DocumentID var id: String?
    
    var name = ""
    var address = ""
    
    var dictionary: [String: Any] {
        return ["name": name, "address": address]
    }
    
    
}
