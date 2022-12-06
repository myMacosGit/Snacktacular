//
//  SpotDetailView.swift
//  Snacktacular
//
//  Created by Richard Isaacs on 17.11.22.
//

import SwiftUI
import MapKit

struct SpotDetailView: View {
    
    struct Annotation: Identifiable {
        let id = UUID().uuidString
        var name: String
        var address: String
        var coordinate: CLLocationCoordinate2D
        
    }
    @EnvironmentObject var spotVM : SpotViewModel
    @EnvironmentObject var locationManager : LocationManager
    @State var spot: Spot
    @State private var showPlaceLookupSheet = false
    @State private var mapRegion = MKCoordinateRegion()
    @State private var annotations: [Annotation] = []
    @Environment (\.dismiss) private var dismiss
    
    let regionSize = 500.0 // meterw
    
    var body: some View {
        
        let _ = print(">>>>>  View/SpotDetailView")
        
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
                .onChange(of: spot) { _ in
                    annotations = [Annotation(name:spot.name, address: spot.address, coordinate: spot.coordinate)]
                    mapRegion.center = spot.coordinate
                }
            Spacer()
            
        } // VStack
        .onAppear{
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
            if spot.id == nil { // New spot, so Cancel/Save
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
            } // if
        } // .toolbar
        .sheet(isPresented: $showPlaceLookupSheet) {
            PlaceLookupView(spot: $spot)
        } // sheet
    } // View
} // SpotDetailView

struct SpotDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SpotDetailView(spot: Spot())
                .environmentObject(SpotViewModel())
                .environmentObject(LocationManager())
        }
    }
}
