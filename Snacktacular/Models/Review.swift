//
//  Review.swift
//  Snacktacular
//
//  Created by Richard Isaacs on 04.12.22.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct Review: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
   
    var title:String = ""
    var body = ""
    var rating = 0
    var reviewer = Auth.auth().currentUser?.email ?? "email?"
    var postedOn = Date()
    
    var dictionary: [String: Any] {
        return ["title": title,
                "body": body,
                "rating": rating,
                "reviewer": reviewer,
                "postedOn": Timestamp(date: Date() ) ]
    }
    
}
