//
//  ReusableProfileContent.swift
//  SocialMedia
//
//  Created by Aditya Inamdar on 16/02/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct ReusableProfileContent: View {
    var user: User
    @State private var fetchedPosts:[Post]=[]
    var body: some View {
        ScrollView(.vertical,showsIndicators: false) {
            LazyVStack{
                HStack(spacing: 12) {
                    WebImage(url: user.userProfileURL)
                        .placeholder {
                            Image("nullProfilePic")
                                .resizable()
                        }
                        .resizable()
                        .aspectRatio( contentMode: .fill)
                        .frame(width: 100,height: 100)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading,spacing: 6) {
                        Text(user.userName)
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text(user.userBio)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(3)
                        
                        if let bioLink = URL(string: user.userBioLink) {
                            Link(user.userBioLink, destination: bioLink)
                                .font(.callout)
                                .tint(.blue)
                                .lineLimit(1)
                        }
                    }
                    .hAlign(.leading)
                }
                Text("Post's")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .hAlign(.leading)
                    .padding(.vertical,15)
                
                ReuseablePostsView(basedOnUID: true, uid: user.userUID, posts: $fetchedPosts)
            }
            .padding(15)
        }
    }
}

//struct ReusableProfileContent_Previews: PreviewProvider {
//    static var previews: some View {
//        ReusableProfileContent()
//    }
//}
