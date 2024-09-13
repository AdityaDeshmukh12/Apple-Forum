//
//  SocialMediaApp.swift
//  SocialMedia
//
//  Created by Aditya Inamdar on 14/02/23.
//

import SwiftUI
import Firebase
@main
struct SocialMediaApp: App {
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
