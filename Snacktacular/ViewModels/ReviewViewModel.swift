//
//  ReviewViewModel.swift
//  Snacktacular
//
//  Created by Richard Isaacs on 16.12.22.
//

import Foundation
//
//  ReviewViewModel.swift
//  Snacktacular
//
//  Created by Richard Isaacs on 17.11.22.
//

import FirebaseFirestore

@MainActor


class ReviewViewModel: ObservableObject {
    @Published var review = Review()
    
    
    func readReview (spot:Spot, review: Review) async -> Bool {
        
        let db = Firestore.firestore()  // let db line error?
        
        guard let spotID = spot.id else
        {
            print ("ERROR: spot.id - nil")
            return false
        }
        
        let collectionString = "spots/\(spotID)/reviews"

        if let id = review.id {  // review must already exist, so save
            // Update
            do {
                var rc: DocumentSnapshot // new
                try await rc = db.collection(collectionString).document(id).getDocument()
                print ("Read Review Data read successfully")
                rc.data()
                return true
            } catch {
                print("ERROR: could not update data in 'reviews' \(error.localizedDescription)")
                return false

            }
        } else { // no id, then create new review
            // Add
            do {
                let rc = try await db.collection(collectionString).addDocument(data: review.dictionary)  // warning about not using return
                print ("Review created data added successfully1, rc = \(rc)")
                print ("Review created data added successfully2, rc = \(rc.documentID)")
                return true
            } catch {
                print("ERROR: could not create a new review in 'reviews' \(error.localizedDescription)")
                return false
            }
        } // if

        
        
    }
    
    func saveReview(spot:Spot, review: Review) async -> Bool {
        let db = Firestore.firestore()  // let db line error?
        
        
        guard let spotID = spot.id else
        {
            print ("ERROR: spot.id - nil")
            return false
        }
        
        let collectionString = "spots/\(spotID)/reviews"
        
        print ("collectionString \(collectionString)     \(String(describing: review.id))")


        if let id = review.id {  // review must already exist, so save
            // Update
            do {
                try await db.collection(collectionString).document(id).setData(review.dictionary)
                print ("Review Data update successfully")
                return true
            } catch {
                print("ERROR: could not update data in 'reviews' \(error.localizedDescription)")
                return false

            }
        } else { // no id, then create new review
            // Add
            do {
                let rc = try await db.collection(collectionString).addDocument(data: review.dictionary)  // warning about not using return
                print ("Review created data added successfully1, rc = \(rc)")
                print ("Review created data added successfully2, rc = \(rc.documentID)")
                return true
            } catch {
                print("ERROR: could not create a new review in 'reviews' \(error.localizedDescription)")
                return false
            }
        } // if
    } // saveReview
    
    
    func deleteReview(spot: Spot, review: Review) async -> Bool {
        
        let db = Firestore.firestore()
        
        guard let spotID = spot.id, let reviewID = review.id else {
            print("ERROR: spot.id = \(String(describing: spot.id ?? nil))), review.id = \(String(describing: review.id ?? nil)))  this should not happen")
            return false
        }
        
        do {
            
            // If the collection name is wrong, there is still a OK delete without deleting the review
            print("----- DELETE: spot.id = \(String(describing: spot.id ?? nil))), review.id = \(String(describing: review.id ?? nil)))")

            
            var before:NSNumber = 0
            // Check if review deleted
            let countQuery1 = db.collection("spots").document(spotID).collection("reviews").count
            do {
              let snapshot = try await countQuery1.getAggregation(source: .server)
              print(snapshot.count)
                before = snapshot.count
            } catch {
              print(error);
            }

            
            
            let _ = try await db.collection("spots").document(spotID).collection("reviewsXXX").document(reviewID).delete()



            // Check if review deleted
            var after:NSNumber = 0
            let countQuery2 = db.collection("spots").document(spotID).collection("reviews").count
            do {
              let snapshot = try await countQuery2.getAggregation(source: .server)
              print(snapshot.count)
                after = snapshot.count
            } catch {
              print(error);
            }
            if before == after {
                print ("delete failed")
            }
            
            print ("Document successfully deleted")
        
            return true
        } catch {
            print("ERROR: could not delete review in 'reviews' \(error.localizedDescription)")
            return false
        }
    } // deleteReview
    
    
} // ReviewViewModel
