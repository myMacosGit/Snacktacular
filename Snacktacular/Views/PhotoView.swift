//
//  PhotoView.swift
//  Snacktacular
//
//  Created by Richard Isaacs on 27.01.23.
//

import SwiftUI

struct PhotoView: View {
    @EnvironmentObject var spotVM: SpotViewModel
    @State private var photo = Photo()
    @Environment(\.dismiss) private var dismiss

    var uiImage: UIImage
    
    var spot: Spot
    
    var body: some View {
        
        NavigationStack {
            VStack {
                Spacer()
                
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                
                Spacer()
                
                TextField("Description", text: $photo.description)
                    .textFieldStyle(.roundedBorder)
                
                Text ("by: \(photo.reviewer) on: \(photo.postedOn.formatted(date: .numeric, time: .omitted)   )")
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            } // VStack
            .padding()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .automatic) {
                    Button("Save") {
                        Task {
                            let success = await spotVM.saveImage(spot: spot,
                                                                 photo: photo,
                                                                 image: uiImage)
                            if success {
                                dismiss()
                            }
                        }
                    }
                }
            }
        } // NavigationStack
    } // View
} // struct

struct PhotoView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoView(uiImage: UIImage(named: "pizza") ?? UIImage(), spot: Spot() )
            .environmentObject(SpotViewModel())
    }
}
