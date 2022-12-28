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


struct SpotDetailView: View {
    
    struct Annotation: Identifiable {
        let id = UUID().uuidString
        var name: String
        var address: String
        var coordinate: CLLocationCoordinate2D
        
    }
    
    @EnvironmentObject var reviewVM : ReviewViewModel //
    
    @EnvironmentObject var spotVM : SpotViewModel
    @EnvironmentObject var locationManager : LocationManager
    // Variable below does not have the right path, change in .onAppear
    @FirestoreQuery(collectionPath: "spots") var reviews: [Review]
    
    //@FirestoreQuery(collectionPath: "spots") var myspots: [Spot]
    
    
    @State var spot: Spot
    
    @State private var showPlaceLookupSheet = false
    @State private var showReviewViewSheet = false
    @State private var showSaveAlert = false
    @State private var showingAsSheet = false
    
    
    @State private var mapRegion = MKCoordinateRegion()
    @State private var annotations: [Annotation] = []
    
    @Environment (\.dismiss) private var dismiss
    
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
            List{
                Section {
                    
                    let _ = print ("count = \(reviews.count)")
                    let _ = print ("count.spot = \(spot.name)")
                    
                    
                    //let _ = print ("myspots = \(myspots.count)")
                    
                    let _ = print ("reviews.path = \($reviews.path)")
                    
            
                    
                    ForEach(reviews) { review in
                        NavigationLink {
                            ReviewView(spot:spot, review: review)
                        } label: {
                            Text("\(review.title)") //TODO: build a custom cell showing stars
                        }
                    }
                } header: {
                    HStack{
                        Text("Avg. Rating:")
                            .font(.title2)
                            .bold()
                        Text("4.5") // TODO: change
                            .font(.title)
                            .fontWeight(.black)
                            .foregroundColor(Color("SnackColor"))
                        
                        Spacer()
                        Button("Rate It") {
                            if spot.id == nil {
                                showSaveAlert.toggle()
                            } else {
                                showReviewViewSheet.toggle()
                            }
                            
                            let _ = print ("-------  \($showReviewViewSheet)  ")
                            
                        }
                        .buttonStyle(.borderedProminent)
                        .bold()
                        .tint(Color("SnackColor"))
                        
                    } // HStack
                } // header
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
        .alert("Cannot Rate Place Unless Saved", isPresented: $showSaveAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Save", role: .none) {
                Task {
                    let success = await spotVM.saveSpot(spot: spot)
                    spot = spotVM.spot
                    if success {
                        // If we did not update the path after saving spot, we would not to show the new reviews added
                        $reviews.path = "spots/\(spot.id ?? "")/reviews"
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
