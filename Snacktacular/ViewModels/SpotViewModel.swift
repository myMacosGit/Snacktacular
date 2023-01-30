//
//  SpotViewModel.swift
//  Snacktacular
//
//  Created by Richard Isaacs on 17.11.22.
//

import Foundation
import FirebaseFirestore
import UIKit
import FirebaseStorage


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
    
    
    func saveImage(spot: Spot, photo: Photo, image: UIImage) async -> Bool {
        
        guard let spotID = spot.id else {
            print ("ERROR: spot.id == nil")
            return false
        }
        
        var photoName = UUID().uuidString
        if photo.id != nil {
            photoName = photo.id! // force unwrap, If I have a photo.id, so use this a the photoname. This happens if we're updating a existing Photo's description info. It'll resave the photo, but it just overwrites the existing one.
        }
        
        let storage = Storage.storage()
        let storageRef = storage.reference().child("\(spotID)/\(photoName).jpeg")
        
        
        print ("----- spotID = \(spotID)")
        print ("----- photoName = \(photoName)")
        
        print ("----- storageRef = \(storageRef)")
        
        guard let resizedImage = image.jpegData(compressionQuality: 0.2) else {
            print ("ERROR: could not resize image")
            return false
        }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg" // Setting metadata allows you to see console image in the web browser. This setting will work for png as well as jpeg
        
        var imageURLString = "" // set this after the image successfuly saved
        
        do {
            let _ = try await storageRef.putDataAsync(resizedImage, metadata: metadata)
            print ("Image saved")
            do {
                let imageURL = try await storageRef.downloadURL()
                print("1")
                imageURLString = "\(imageURL)" // save this to Cloud Firestore as part of document in 'photos' collection, below
                print("2")
 
                print ("----- URL \(imageURL)")
                print("3")
 
            } catch {
                print ("ERROR: uploading image to Firestorage")
                return false
            }
            
        } catch {
            print ("ERROR: uploading image to FirebaseStorage")
            return false
        } // do
        
        // Now save to the 'photos' collection of the spot document "spotID"
        
        let db = Firestore.firestore()
        let collectionString = "spots/\(spotID)/photos"
        print ("----- collectionString \(collectionString)")
        do {
            var newPhoto = photo  // photo constant argument
            newPhoto.imageURLString = imageURLString
            try await db.collection(collectionString).document(photoName).setData(newPhoto.dictionary)
            print ("Data updated successfully")
            
            print ("----- photo document \(collectionString) \\  \(photoName)")
            return true
        } catch {
            print ("ERROR: could not update data in photos for spotID \(spotID)")
            return false
        } // do
        
    } // saveImage
    
} // SpotViewModel
