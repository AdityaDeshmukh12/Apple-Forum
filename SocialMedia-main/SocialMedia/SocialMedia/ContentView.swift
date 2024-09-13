//
//  ContentView.swift
//  SocialMedia
//
//  Created by Aditya Inamdar on 14/02/23.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("log_status") var logStatus:Bool = false
    var body: some View {
        if logStatus == true {
           MainView()
        }
        else {
            LoginView()
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
