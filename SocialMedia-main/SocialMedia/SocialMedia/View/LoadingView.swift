//
//  LoadingView.swift
//  SocialMedia
//
//  Created by Aditya Inamdar on 16/02/23.
//

import SwiftUI

struct LoadingView: View {
    @Binding var show: Bool
    var body: some View {
        ZStack {
            if show {
                Group {
                    Rectangle()
                        .fill(.black.opacity(0.25))
                        .ignoresSafeArea()
                    
                    ProgressView()
                        .padding(15)
                        .background(.white,in: RoundedRectangle(cornerRadius: 15,style: .circular))
                }
            }
        }.animation(.easeIn(duration: 0.25), value: show)
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView(show: .constant(true))
    }
}
