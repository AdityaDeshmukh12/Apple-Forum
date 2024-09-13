//
//  SearchUserView.swift
//  SocialMedia
//
//  Created by Aditya Inamdar on 17/02/23.
//

import SwiftUI
import FirebaseStorage
import FirebaseFirestore

struct SearchUserView: View {
    @State private var fetchedUser:[User] = []
    @State private var searchText: String = ""
    @Environment(\.dismiss)private var dismiss
    var body: some View {
        List {
            ForEach(fetchedUser) { user in
                NavigationLink{
                    ReusableProfileContent(user: user)
                }label: {
                    Text(user.userName)
                        .font(.callout)
                        .hAlign(.leading)
                }
            }
        }
        .listStyle(.plain)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Search User")
        .searchable(text: $searchText)
        .onSubmit(of: .search) {
            Task{
                await searchUsers()
            }
        }
        .onChange(of: searchText, perform: { newValue in
            if newValue.isEmpty {
                fetchedUser = []
            }
        })
    }
    func searchUsers() async  {
        do {
            let queryLowerCased = searchText.lowercased()
            let queryUpperCased = searchText.uppercased()
            
            let documents = try await Firestore.firestore().collection("Users").whereField("userName",isGreaterThanOrEqualTo: queryUpperCased)
                .whereField("userName",isLessThanOrEqualTo: "\(queryLowerCased)\u{f8ff}")
                .getDocuments()
            
            let users = try documents.documents.compactMap { doc->User? in
                try doc.data(as: User.self)
            }
            await MainActor.run(body: {
                fetchedUser = users
            })

        }catch{
            print(error.localizedDescription)
        }
    }
}

struct SearchUserView_Previews: PreviewProvider {
    static var previews: some View {
        SearchUserView()
    }
}
//    .toolbar {
//        ToolbarItem(placement: .navigationBarTrailing) {
//            Button("Cancel"){
//                dismiss()
//            }
//            .tint(.black)
//        }
//    }
