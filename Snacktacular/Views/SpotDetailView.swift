//
//  SpotDetailView.swift
//  Snacktacular
//
//  Created by Richard Isaacs on 17.11.22.
//

import SwiftUI
import MapKit
import Firebase
import FirebaseFirestoreSwift
import PhotosUI


struct SpotDetailView: View {
    
    enum ButtonPressed {
        case review, photo
    }
    
    struct Annotation: Identifiable {
        let id = UUID().uuidString
        var name: String
        var address: String
        var coordinate: CLLocationCoordinate2D
        
    }
    @Environment (\.dismiss) private var dismiss
    
    @EnvironmentObject var reviewVM : ReviewViewModel //
    
    @EnvironmentObject var spotVM : SpotViewModel
    @EnvironmentObject var locationManager : LocationManager
    // Variable below does not have the right path, change in .onAppear
    @FirestoreQuery(collectionPath: "spots") var reviews: [Review]
    @FirestoreQuery(collectionPath: "spots") var photos: [Photo]
    
    //@FirestoreQuery(collectionPath: "spots") var myspots: [Spot]
    
    
    @State var spot: Spot
    @State var newPhoto = Photo()
    
    @State private var showPlaceLookupSheet = false
    @State private var showReviewViewSheet = false
    @State private var showSaveAlert = false
    @State private var showingAsSheet = false
    @State private var showPhotoViewSheet = false
    
    
    @State private var buttonPressed = ButtonPressed.review
    @State private var uiImageSelected = UIImage()
    
    
    @State private var mapRegion = MKCoordinateRegion()
    @State private var annotations: [Annotation] = []
    @State private var selectedPhoto: PhotosPickerItem?
    
    var avgRating: String {  // can not use state variables as computed properties
        guard reviews.count != 0 else {
            return "-.-"
        }
        // Get averagg pf all reviews in array
        let averageValue = Double(reviews.reduce(0) {$0 + $1.rating}) / Double(reviews.count)
        
        return String(format: "%.1f", averageValue)
    }
    
    
    
    let regionSize = 500.0 // meters
    
    var previewRunning = false
    
    var body: some View {
        
        let _ = print(">>>>>  View/SpotDetailView")
        
        
        let _ = print (">>reviews.path.spots.name = \(spot.name)")
        let _ = print (">>reviews.path = \($reviews.path)")
        let _ = print (">>reviews = \($reviews)")
        let _ = print (">>count = \(reviews.count)")
        
        VStack  {
            Group {
                Text("\(String(describing: Auth.auth().currentUser?.email)) ")
                TextField("Name", text: $spot.name)
                    .font(.title)
                TextField("Address", text: $spot.address)
                    .font(.title2)
            } //Group
            .disabled(spot.id == nil ? false : true)
            
            .textFieldStyle(.roundedBorder)
            .overlay {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(.gray.opacity(0.5), lineWidth: spot.id == nil ? 2 : 0)
            }
            .padding(.horizontal)
            
            Map(coordinateRegion: $mapRegion,
                showsUserLocation: true,
                annotationItems: annotations) { annotation in
                MapMarker(coordinate: annotation.coordinate)
            }
            .frame(height: 250)
            .onChange(of: spot) { _ in
                annotations = [Annotation(name:spot.name, address: spot.address, coordinate: spot.coordinate)]
                    mapRegion.center = spot.coordinate
            } // onChange
            
            SpotDetailPhotosScrollView(photos: photos, spot: spot)
            
            HStack{
                Group {
                    Text("Avg. Rating:")
                        .font(.title2)
                        .bold()
                    Text(avgRating)
                        .font(.title)
                        .fontWeight(.black)
                        .foregroundColor(Color("SnackColor"))
                } // Group
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                
                Spacer()
                
                Group {
                    PhotosPicker(selection: $selectedPhoto, matching: .images, preferredItemEncoding: .automatic) {
                        Image(systemName: "photo")
                        Text("Photo")
                        
                    } // PhotoPicker
                    .onChange(of: selectedPhoto) { newValue in
                        Task {
                            do {
                                if let data = try await newValue?.loadTransferable(type: Data.self) {
                                    
                                    if let uiImage = UIImage(data: data) {
                                        uiImageSelected = uiImage
                                        buttonPressed = .photo
                                        print ("Successfully selected image")
                                        newPhoto = Photo() // clears out contents, if you have more than one photo in a row for this spot
                                        if spot.id == nil {
                                            showSaveAlert.toggle()
                                        } else {
                                            showPhotoViewSheet.toggle()
                                        }
                                        
                                    }
                                }
                            } catch {
                                print ("ERROR: selecting image failed \(error.localizedDescription)" )
                            } // do
                        }
                    }
                    
                    Button(action: {
                        buttonPressed = .review
                        if spot.id == nil {
                            showSaveAlert.toggle()
                        } else {
                            showReviewViewSheet.toggle()
                        }
                    }, label: {
                        Image(systemName: "star.fill")
                        Text("Rate")
                    })
                } // Group
                .font(Font.caption)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                
                .buttonStyle(.borderedProminent)
                .tint(Color("SnackColor"))
                
            } // HStack
            .padding(.horizontal)
            
            
            List{
                Section {
                    
                    //let _ = print ("count = \(reviews.count)")
                    //let _ = print ("count.spot = \(spot.name)")
                    
                    
                    //let _ = print ("myspots = \(myspots.count)")
                    
                    let _ = print ("reviews.path = \($reviews.path)")
                    
                    
                    
                    ForEach(reviews) { review in
                        NavigationLink {
                            ReviewView(spot:spot, review: review)
                        } label: {
                            //Text("\(review.title)") //TODO: build a custom cell showing stars
                            SpotReviewRowView(review: review)
                        }
                    }
                }
                .headerProminence(.increased)
            } // List
            .listStyle(.plain) // default list style
            
            Spacer()
            
        } // VStack
        .onAppear {
            if !previewRunning  && spot.id != nil {
                $reviews.path = "spots/\(spot.id ?? "")/reviews"
                //$reviews.path = "/spots/Olg2LKocBd7d0ugy9WEb/reviews"
                
                
                //$reviews.path = "spots/EzNVBPlrKnOd7r27RHwZ/reviews"
                
                print ("reviews.path.spots.name = \(spot.name)")
                print ("reviews.path = \($reviews.path)")
                print ("reviews = \($reviews)")
                
                
                //$myspots.path = "spots"
                //print ("myspots.path = \($myspots.path)")
                //print ("myspots = \($myspots)")
                
                $photos.path = "spots/\(spot.id ?? "")/photos"
                print ("photos.path = \($photos.path)")
                
            } else { // spot.id starts out as nil
                showingAsSheet = true
            }
            
            if spot.id != nil { // center, if spot exists
                mapRegion = MKCoordinateRegion(center: spot.coordinate,
                                               latitudinalMeters: regionSize,
                                               longitudinalMeters: regionSize)
            } else { //center on device location
                Task { // neee to enbedd Task, map may not update may not show
                    mapRegion = MKCoordinateRegion(
                        center: locationManager.location?.coordinate ?? CLLocationCoordinate2D(),
                        latitudinalMeters: regionSize,
                        longitudinalMeters: regionSize)
                    
                }
                
            }
            annotations = [Annotation(name:spot.name, address: spot.address, coordinate: spot.coordinate)]
        } // onAppear
        
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(spot.id == nil)
        .toolbar {
            
            if showingAsSheet { // New spot, so show Cancel / Save buttons
                
                if spot.id == nil && showingAsSheet { // New spot, so Cancel/Save
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            Task {
                                let success = await spotVM.saveSpot(spot: spot)
                                if success {
                                    dismiss()
                                } else {
                                    print ("ERROR: saving spot")
                                }
                            } // Task
                            dismiss()
                        } // Button
                    } // ToolbarItem
                    
                    ToolbarItemGroup(placement: .bottomBar) {
                        Spacer()
                        Button {
                            showPlaceLookupSheet.toggle()
                            
                        } label: {
                            Image(systemName: "magnifyingglass")
                            Text("Lookup Place")
                        }
                    } // ToolbarItem
                } else if showingAsSheet && spot.id != nil {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }// spot.id == nil
                
            } // if
        } // .toolbar
        .sheet(isPresented: $showPlaceLookupSheet) {
            PlaceLookupView(spot: $spot)
        } // sheet
        
        .sheet(isPresented: $showReviewViewSheet) {
            NavigationStack {
                ReviewView(spot: spot, review: Review())
            }
        } // sheet
        
        .sheet(isPresented: $showPhotoViewSheet) {
            NavigationStack{
                PhotoView(photo: $newPhoto, uiImage: uiImageSelected, spot: spot)
            }
        }
        .alert("Cannot Rate Place Unless Saved", isPresented: $showSaveAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Save", role: .none) {
                Task {
                    let success = await spotVM.saveSpot(spot: spot)
                    spot = spotVM.spot
                    if success {
                        // If we did not update the path after saving spot, we would not to show the new reviews added
                        
                        $reviews.path = "spots/\(spot.id ?? "")/reviews"
                        
                        $photos.path = "spots/\(spot.id ?? "")/photos"
                        
                        switch (buttonPressed) {
                            case .review:
                                showReviewViewSheet.toggle()
                                
                            case .photo:
                                showPhotoViewSheet.toggle()
                        }
                        
                        
                        
                        showReviewViewSheet.toggle()
                    } else {
                        print ("ERROR: error saving spot")
                    }
                } // task
            }
        } message: {
            Text("Would you like to save this alert first so that you can enter a review?")
        }
        
    } // View
} // SpotDetailView

struct SpotDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SpotDetailView(spot: Spot(), previewRunning: true)
                .environmentObject(SpotViewModel())
                .environmentObject(LocationManager())
        }
    }
}
