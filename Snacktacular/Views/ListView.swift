//
//  ListView.swift
//  Snacktacular
//
//  Created by Richard Isaacs on 09.11.22.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct ListView: View {
    
    @FirestoreQuery(collectionPath: "spots") var spots: [Spot]
    
    @State private var sheetIsPresented = false
    @Environment (\.dismiss) private var dismiss
    
    var body: some View {

        let _ = print (">>>>> ListView/View")
        let _ = print ("\(spots.count)")
        let _ = print ("\($spots.path)")

        NavigationStack {
            List(spots) { spot in
                NavigationLink {
                    SpotDetailView(spot: spot)
                } label: {
                    Text(spot.name)
                        .font(.title2)
                }
            } // List
            
            .listStyle(.plain)
            .navigationTitle("Snack Spots")
            .navigationBarTitleDisplayMode(.inline)// bug
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Sign Out") {
                        do {
                            try Auth.auth().signOut()
                            print ("🪵➡️ Log out successful")
                            dismiss()
                        } catch {
                            print("ERROR: Could not sign out \(error.localizedDescription)")
                        }
                    } // Button
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        sheetIsPresented.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                } // Button
            } // toolbar
            .sheet(isPresented: $sheetIsPresented) {
                NavigationStack {
                    SpotDetailView(spot: Spot())
                }
            } // sheet
        } // NavigationStack
    } // body
} // ListView

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ListView()
        }
    }
}
