//
//  SpotDetailPhotosScrollView.swift
//  Snacktacular
//
//  Created by Richard Isaacs on 29.01.23.
//

import SwiftUI

struct SpotDetailPhotosScrollView: View {
    
    struct FakePhoto: Identifiable {
        let id = UUID().uuidString
        var imageURLString = "https://firebasestorage.googleapis.com:443/v0/b/snacktacularui-1272f.appspot.com/o/4T1PIOl1VTd2t50A1Sme%2FF22862C7-845F-49EF-B5FB-38233101AA60.jpeg?alt=media&token=a594457d-5260-43f8-a028-6354b56e3293"
        
    }
    
    //let photos = [FakePhoto(), FakePhoto(),FakePhoto(),FakePhoto(),FakePhoto()]
    
    @State private var showPhotoViewerView = false
    @State private var uiImage = UIImage()
    @State var selectedPhoto = Photo()
    var photos:[Photo]
    var spot:Spot
    
    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: true) {
            HStack (spacing: 4) {
                ForEach(photos) { photo in
                    let imageURL = URL(string: photo.imageURLString) ?? URL(string: "")
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                        // order is important
                            //.scaledToFit()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipped()
                            .onTapGesture {
                                let renderer = ImageRenderer(content: image)
                                selectedPhoto = photo
                                uiImage = renderer.uiImage ?? UIImage()
                                showPhotoViewerView.toggle()
                                
                            }
                    } placeholder: {
                        ProgressView()
                            .frame(width: 80, height: 80)
                    }
                } // ForEach
            } // HStack
        } // ScrollView
        .frame(height:80)
        .padding(.horizontal, 4)
        .sheet(isPresented: $showPhotoViewerView) {
            PhotoView(photo: $selectedPhoto, uiImage: uiImage, spot: spot)
        }
    } // View
}

struct SpotDetailPhotosScrollView_Previews: PreviewProvider {
    static var previews: some View {
        SpotDetailPhotosScrollView(photos: [Photo(imageURLString: "https://firebasestorage.googleapis.com:443/v0/b/snacktacularui-1272f.appspot.com/o/4T1PIOl1VTd2t50A1Sme%2FF22862C7-845F-49EF-B5FB-38233101AA60.jpeg?alt=media&token=a594457d-5260-43f8-a028-6354b56e3293")], spot: Spot(id: "4T1PIOl1VTd2t50A1Sme"))
    }
}
