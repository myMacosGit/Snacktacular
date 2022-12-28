//
//  SpotViewModel.swift
//  Snacktacular
//
//  Created by Richard Isaacs on 17.11.22.
//

import Foundation
import FirebaseFirestore


@MainActor

class SpotViewModel : ObservableObject {
    @Published var spot = Spot()
    
    func saveSpot(spot:Spot) async -> Bool {
        let db = Firestore.firestore()  // let db line error?
        
        if let id = spot.id {
            // Update
            do {
                try await db.collection("spots").document(id).setData(spot.dictionary)
                print ("Data update successfully")
                return true
            } catch {
                print("ERROR: could not update data in 'spots' \(error.localizedDescription)")
                return false
            }
        } else {
            // Add
            do {
                let documentRef = try await db.collection("spots").addDocument(data: spot.dictionary)  // warning about not using return
                print ("Data added successfully1, rc = \(documentRef)")
                print ("Data added successfully2, rc = \(documentRef.documentID)")
                self.spot = spot
                self.spot.id = documentRef.documentID
                print ("Data added successfully3, rc = \(self.spot.id ?? "xx")")
                return true
            } catch {
                print("ERROR: could not create a new spot in 'spots' \(error.localizedDescription)")
                return false
            }
        } // if
    } // saveSpot
} // SpotViewModel
