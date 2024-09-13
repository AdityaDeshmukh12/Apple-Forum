//
//  MainView.swift
//  SocialMedia
//
//  Created by Aditya Inamdar on 16/02/23.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            PostsView()
                .tabItem {
                    Image(systemName: "rectangle.portrait.on.rectangle.portrait.angled")
                    Text("Post's")
                }
            ProfileView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Profile")
                }
            ChatGPTView()
                .tabItem {
                    Image(systemName: "ellipsis.message.fill")
                    Text("Chat")
                }
                
        }
        .tint(.black)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
