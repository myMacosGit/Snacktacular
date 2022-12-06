//
//  Review.swift
//  Snacktacular
//
//  Created by Richard Isaacs on 04.12.22.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct Review: Identifiable, Codable {
    @DocumentID var id: String?
    
    var title = ""
    var body = ""
    var rating = 0
    var reviewer = ""
    var postedOn = Date()
    
    var dictionary: [String: Any] {
        return ["title": title,
                "body": body,
                "rating": rating,
                "reviewer": Auth.auth().currentUser?.email ?? "",
                "posted": Timestamp(date: Date() )
        ]
    }
    
}
