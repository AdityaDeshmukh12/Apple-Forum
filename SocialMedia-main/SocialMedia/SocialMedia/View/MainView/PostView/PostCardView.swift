//
//  PostCardView.swift
//  SocialMedia
//
//  Created by Aditya Inamdar on 17/02/23.
//

import SwiftUI
import SDWebImageSwiftUI
import FirebaseFirestore
import FirebaseStorage
import VisionKit
struct PostCardView: View {
    
    var post: Post
    var onUpdate: (Post)->()
    var onDelete: ()->()
    @State var showLiveTextView = false
    
    @State var liveTextImageURL = URL(string: "")
    
    @AppStorage("user_UID") var userUID: String = ""
    @State var docListner: ListenerRegistration?
    
    var body: some View {
        HStack(alignment:.top,spacing: 12) {
            
            WebImage(url: post.userProfileURL)
                .resizable()
                .aspectRatio( contentMode: .fill)
                .frame(width: 35,height: 35)
                .clipShape(Circle())
            VStack(alignment: .leading) {
                Text(post.userName)
                    .font(.callout)
                    .fontWeight(.semibold)
                Text(post.publishedDate.formatted(date:.numeric,time: .shortened))
                    .font(.caption2)
                    .foregroundColor(.gray)
                Text(post.text)
                    .textSelection(.enabled)
                    .padding(.vertical,8)
                
                if let postImageURL = post.imageURL {
                    GeometryReader {
                        let size = $0.size
                        //WebImage(url: postImageURL)
                        AsyncImage(url: postImageURL) { phase in
                            phase.image?.resizable()
                        }
                            //.resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: size.width,height: size.height)
                            .clipShape(RoundedRectangle(cornerRadius: 10,style: .continuous))
                            
                        
                    }
                    .frame(height: 200)
                    .contextMenu {
                        Button {
                            //Live Text View
                            if ImageAnalyzer.isSupported {
                                
                                showLiveTextView = true
                            }
                            else {
                                print("Live text not supported")
                            }
                            
                        } label: {
                            Label("Extract Text", systemImage: "list.bullet.circle.fill")
                        }
                        
                    }
                }
                PostInteraction()
            }
        }
        .hAlign(.leading)
        .overlay(alignment: .topTrailing,content: {
            if post.userUID == userUID {
                Menu {
                    Button("Delete Post",role: .destructive,action: deletePost)
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.caption)
                        .rotationEffect(.init(degrees: -90))
                        .foregroundColor(.black)
                        .padding(8)
                        .contentShape(Rectangle())
                }
                .offset(x:8)
            }
        })
        .onAppear{
            if docListner == nil {
                guard let postID = post.id else {return}
                print("post id is :\(postID)")
                docListner = Firestore.firestore().collection("Posts").document(postID).addSnapshotListener({ snapshot, error in
                    if let snapshot {
                        if snapshot.exists{
                            if let updatedPost = try? snapshot.data(as: Post.self) {
                                onUpdate(updatedPost)
                            }
                        }else {
                            onDelete()
                        }
                    }
                })
            }
        }
        .onDisappear{
            if let docListner {
                docListner.remove()
                self.docListner = nil
            }
        }
        .sheet(isPresented: $showLiveTextView) {
            LiveTextInteractionView(post: post)
        }
       
    }
    
   
    
    
    @ViewBuilder
    func PostInteraction()->some View {
        HStack(spacing: 6) {
            Button(action: likePost) {
                Image(systemName: post.likedIDs.contains(userUID) ? "hand.thumbsup.fill": "hand.thumbsup")
            }
            
            Text("\(post.likedIDs.count)")
                .font(.caption)
                .foregroundColor(.gray)
            
            Button(action: dislikePost) {
                Image(systemName: post.dislikedIDs.contains(userUID) ? "hand.thumbsdown.fill": "hand.thumbsdown")

            }
            .padding(.leading,25)
            
            Text("\(post.dislikedIDs.count)")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .foregroundColor(.black)
        .padding(.vertical,8)
    }
    
    func likePost() {
        Task {
            guard let postID = post.id else {return}
            if post.likedIDs.contains(userUID) {
                try await Firestore.firestore().collection("Posts").document(postID).updateData([
                    "likedIDs": FieldValue.arrayRemove([userUID])
                ])
            } else {
                try await Firestore.firestore().collection("Posts").document(postID).updateData([
                    "likedIDs": FieldValue.arrayUnion([userUID]),
                    "dislikedIDs": FieldValue.arrayRemove([userUID])
                ])
            }
        }
    }
    
    func dislikePost(){
        Task {
            guard let postID = post.id else {return}
            if post.dislikedIDs.contains(userUID) { // when our post has 1 dislike(from me) then tapping it again should remove that dislike 👇
                try await Firestore.firestore().collection("Posts").document(postID).updateData([
                    "dislikedIDs": FieldValue.arrayRemove([userUID])
                ])
            } else {// when our post already has a like from me and i dislike it, it should remove the like and add dislike
               try await Firestore.firestore().collection("Posts").document(postID).updateData([
                    "likedIDs": FieldValue.arrayRemove([userUID]),
                    "dislikedIDs": FieldValue.arrayUnion([userUID])
                ])
            }
        }

    }
    
    func deletePost() {
        Task {
            do {
                if post.imageReferenceID != "" {
                   try await Storage.storage().reference().child("Post_Images").child(post.imageReferenceID).delete()
                }
                guard let postId = post.id else{return}
                try await Firestore.firestore().collection("Posts").document(postId).delete()
            }catch{
                print(error.localizedDescription)
            }
        }
    }
}

//struct PostCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        PostCardView(post: <#Post#>, onUpdate: <#(Post) -> ()#>, onDelete: <#() -> ()#>)
//    }
//}
