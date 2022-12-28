//
//  ReviewView.swift
//  Snacktacular
//
//  Created by Richard Isaacs on 04.12.22.
//

import SwiftUI

struct ReviewView: View {
    @State var spot: Spot
    @State var review: Review
    @StateObject var reviewVM = ReviewViewModel()
    
    @Environment (\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            VStack (alignment: .leading) {
                Text(spot.name)
                    .font(.title)
                    .bold()
                    .multilineTextAlignment(.leading)
                .lineLimit(1)

                Text(spot.address)
                    .padding(.bottom)
            } // VStack

            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Click to Rate:")
                .font(.title2)
                .bold()
            HStack {
                StarsSelectionView(rating: $review.rating)
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.gray.opacity(0.5), lineWidth: 2)
                    }
                
                
                
                //ForEach(0...4, id: \.self) { _ in
                //    Image(systemName: "star.fill")
                //        .tint(.red)
                //        .font(.largeTitle)
                // }
            } // HStack
            .padding(.bottom)
            
            VStack (alignment: .leading) {
                Text("Review Title:")
                    .bold()
                
                TextField("title", text: $review.title)
                    .textFieldStyle(.roundedBorder)
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.gray.opacity(0.5), lineWidth: 2)
                    }
                
                Text("Review")
                    .bold()
                
                TextField("review", text: $review.body, axis: .vertical)
                    .padding(.horizontal, 6)
                    .frame(maxHeight: .infinity, alignment: .topLeading)
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.gray.opacity(0.5), lineWidth: 2)
                    }
            } // VStack
            .padding(.horizontal)
            .font(.title2)
            Spacer()
            
        } // VStack
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    Task {
                        let success = await reviewVM.saveReview(spot:spot, review:review)
                        if success {
                           //    let success1 = await reviewVM.readReview(spot:spot, review:review
                           // print ("======\(success1)")
                            dismiss()
                        } else {
                            print ("ERROR: saving data ReviewView")
                        }
                    }
                    dismiss()
                }
            }
        } // toolbar
    }
}

struct ReviewView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            ReviewView(spot: Spot(name:"Shake Shack",
                                  address:"49 Boyleston St., Chestnut Hill, MA 02467"),
                       review: Review() )
        }
    }
}
