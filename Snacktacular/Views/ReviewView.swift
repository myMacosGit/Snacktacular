//
//  ReviewView.swift
//  Snacktacular
//
//  Created by Richard Isaacs on 04.12.22.
//

import SwiftUI
import Firebase

struct ReviewView: View {
    @StateObject var reviewVM = ReviewViewModel()

    @State var spot: Spot
    @State var review: Review
    @State var postedByThisUser = false
    @State var rateOrReviewerString = "Click to Rate:" // otherwise will say poster email & date
    
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
            
            Text(rateOrReviewerString)
                .font(postedByThisUser ? .title2 : .subheadline)
                .bold(postedByThisUser)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .padding(.horizontal)
            HStack {
                StarsSelectionView(rating: $review.rating)
                    .disabled(!postedByThisUser) // disable if not posted by this user
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.gray.opacity(0.5),
                                    lineWidth: postedByThisUser ? 2: 0)
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
                    //.textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 6)
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.gray.opacity(0.5), lineWidth: postedByThisUser ? 2: 0.3)
                    }
                
                Text("Review")
                    .bold()
                
                TextField("review", text: $review.body, axis: .vertical)
                    .padding(.horizontal, 6)
                    .frame(maxHeight: .infinity, alignment: .topLeading)
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.gray.opacity(0.5), lineWidth: postedByThisUser ? 2: 0.3)
                    }
            } // VStack
            .disabled(!postedByThisUser)  // disable if not posted by this user
            .padding(.horizontal)
            .font(.title2)
            Spacer()
            
        } // VStack
        .onAppear {
            if review.reviewer == Auth.auth().currentUser?.email {
                postedByThisUser = true
                
                let _ = print ("****** reviewer == user \( String(describing: Auth.auth().currentUser?.email)) ")
            } else {
                let reviewPostedOn = review.postedOn.formatted(date: .numeric, time: .omitted)
                rateOrReviewerString = "by: \(review.reviewer) on: \(reviewPostedOn)"
                
                let _ = print ("!!!!! reviewer != user \( String(describing: Auth.auth().currentUser?.email)) ")
            }
            
        } // onAppear
        .navigationBarBackButtonHidden(postedByThisUser) // Hide back button posted by this user
        .toolbar {
            if postedByThisUser {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                } // ToolbarIten

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
                        dismiss() // ???
                    }
                } // toolbarItem
                
                if review.id != nil {
                    ToolbarItemGroup(placement: .bottomBar) {
                        Spacer()
                        Button {
                            Task {
                                let success = await reviewVM.deleteReview(spot: spot, review: review)
                                
                                if success {
                                    dismiss()
                                }
                            } // task
                            

                            /*
                            // Deleted but can still read the deleted the review
                            
                            Task {
                                let success = await reviewVM.readReview(spot:spot, review:review)
                                if success {
                                    dismiss()
                                } else {
                                    print ("ERROR: saving data ReviewView")
                                }
                            } // task
                             */ 
                            
                        } label: {
                            Image(systemName: "trash")
                        }
                    } // ToolbarItemGroup
                } // if
                
            } // if
            
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
