//
//  Photo.swift
//  Snacktacular
//
//  Created by Richard Isaacs on 26.01.23.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct Photo: Identifiable, Codable {
    @DocumentID var id: String?
    var imageURLString = "" // hold the URL reference to image
    var description = ""
    var reviewer = Auth.auth().currentUser?.email ?? "email"
    var postedOn = Date()
    
    var dictionary: [String: Any] {
        return ["imageURLString" : imageURLString,
                "description" : description,
                "reviewer" : reviewer,
                "postedOn" : Timestamp(date: Date())
        ]
    }
}
