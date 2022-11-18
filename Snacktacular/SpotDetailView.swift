//
//  SpotDetailView.swift
//  Snacktacular
//
//  Created by Richard Isaacs on 17.11.22.
//

import SwiftUI

struct SpotDetailView: View {
    @EnvironmentObject var spotVM : SpotViewModel
    @State var spot: Spot
    @Environment (\.dismiss) private var dismiss
    
    
    var body: some View {
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
            
            Spacer()

        } // VStack
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(spot.id == nil)
        .toolbar {
            if spot.id == nil { // New spot, so hosw Cancel/Save
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
                }




            } // if
        } // .toolbar
    }
}

struct SpotDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SpotDetailView(spot: Spot())
                .environmentObject(SpotViewModel())
            
            
        }
    }
}
