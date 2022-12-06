//
//  PlaceLookupView.swift
//  PlaceLookupDemo
//
//  Created by Richard Isaacs on 21.11.22.
//

import SwiftUI
import MapKit

struct PlaceLookupView: View {
    
    let a: () = print(">>>>> PlaceLookupView")
    
    @EnvironmentObject var locationManager: LocationManager
    
    @State private var searchText = ""
    
    
    // Parameter for call to this struct
    // Refer back to variable in ContentView
    // https://www.hackingwithswift.com/quick-start/swiftui/what-is-the-binding-property-wrapper
    
    @Binding var spot : Spot
    
    @StateObject var placeVM = PlaceViewModel()
    
    @Environment (\.dismiss) private var dismiss
    //var places = ["here","there","everywhere",]
    
    var body: some View {
        let _: () = print("----> PlaceLookupView")
        NavigationStack {
            
            let _ = print("$$$$$ NavigationStack = \(placeVM.places.count)")
            
            // Nothing displayed if places nil
            List(placeVM.places) { place in
                VStack (alignment: .leading) {
                    Text(place.name)
                        .font(.title2)
                    Text(place.address)
                        .font(.callout)
                } // VStack
                .onTapGesture {
                    spot.name = place.name
                    spot.address = place.address
                    spot.latitude = place.latitude
                    spot.longitude = place.longitude
                    
                    print ("+++++ returnedPlace \(place.name)")
                    dismiss()
                } // onTapGesture
            } // List
            .listStyle(.plain)
            .searchable(text: $searchText)
            .onChange(of: searchText, perform: { text in
                if !text.isEmpty {
                    placeVM.search(text: text, region: locationManager.region)
                } else {
                    // Entry some characters, then remove all characters
                    placeVM.places = [] // text field was erased
                } // if
            }) // onChange
            
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Dismiss") {
                        dismiss()
                    }
                }
            } // toolbar
        } // NavigationStack
    } // View
} // PlaceLookupView

struct PlaceLookupView_Previews: PreviewProvider {
    static var previews: some View {
        PlaceLookupView(spot: .constant(Spot()) )
            .environmentObject(LocationManager())
    }
}
