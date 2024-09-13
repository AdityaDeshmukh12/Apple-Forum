//
//  ReuseablePostsView.swift
//  SocialMedia
//
//  Created by Aditya Inamdar on 17/02/23.
//

import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseFirestore


struct ReuseablePostsView: View {
    var basedOnUID:Bool = false
    var uid: String = ""
    @Binding var posts: [Post]
    @State var isFetching: Bool = true
    @State var paginationDoc: QueryDocumentSnapshot?
    
    var body: some View {
        ScrollView(.vertical,showsIndicators: false){
            LazyVStack {
                if isFetching {
                    ProgressView()
                        .padding(.top,30)
                }else {
                    if posts.isEmpty {
                        Text("No Posts Found")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.top,30)
                    } else {
                        Posts()
                    }
                }
            }
            .padding(15)
        }
        .refreshable {
            guard !basedOnUID else{return}
            isFetching = true
            posts = []
            paginationDoc = nil
            await fetchPosts()
        }
        .task {
            guard posts.isEmpty else {return} //if isEmpty returns true then run fetchPosts()
            await fetchPosts()
        }
    }
    
    @ViewBuilder
    func Posts()->some View {
        ForEach(posts) { post in
            PostCardView(post: post) { updatedPost in
                if let index = posts.firstIndex(where: { post in
                    post.id == updatedPost.id
                }) {
                    posts[index].likedIDs = updatedPost.likedIDs
                    posts[index].dislikedIDs = updatedPost.dislikedIDs
                }
            } onDelete: {
                withAnimation(.easeOut(duration: 0.25)){
                    posts.removeAll{post.id == $0.id}
                }
            }
            .onAppear{
                if post.id == posts.last?.id && paginationDoc != nil {
                    print("Fetch new post")
                    Task {
                        await fetchPosts()
                    }
                }
            }
            Divider()
                .padding(.horizontal,-15)

        }
    }
    
    func fetchPosts()async {
        do {
            var query: Query!
            if let paginationDoc {
                query = Firestore.firestore().collection("Posts").order(by: "publishedDate",descending: true).start(afterDocument: paginationDoc).limit(to: 20)
            }else{
                query = Firestore.firestore().collection("Posts").order(by: "publishedDate",descending: true).limit(to: 20)
            }
            if basedOnUID{
                query = query.whereField("userUID",isEqualTo: uid)
            }
            let docs = try await query.getDocuments()
            
            let fetchedPosts = docs.documents.compactMap { doc->Post? in
                try? doc.data(as: Post.self)
            }
            print("here::")
            print(fetchedPosts)
            await MainActor.run(body: {
                print("1 is fetching:\(isFetching)")
                posts.append(contentsOf: fetchedPosts)
                paginationDoc = docs.documents.last
                print("2 is fetching:\(isFetching)")
                self.isFetching = false
                print("3 is fetching:\(isFetching)")
            })
        } catch {
            print(error)
        }
    }
}

struct ReuseablePostsView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
