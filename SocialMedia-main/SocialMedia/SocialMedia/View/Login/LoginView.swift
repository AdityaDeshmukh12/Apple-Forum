//
//  LoginView.swift
//  SocialMedia
//
//  Created by Aditya Inamdar on 14/02/23.
//

import SwiftUI
import PhotosUI
import Firebase
import FirebaseStorage
import FirebaseFirestore

struct LoginView: View {
    
    @State var emailId: String = ""
    @State var password: String = ""
    @State var createAccount: Bool = false
    @State var showError: Bool = false
    @State var errorMessage: String = ""
    @State var isLoading: Bool = false
    
    @AppStorage("log_status") var logStatus: Bool = false
    @AppStorage("user_profile_url") var profileURL: URL?
    @AppStorage("user_name") var userNameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    
    var body: some View {
    
        VStack(spacing:10){
            
            Text("Lets sign you in")
                .font(.largeTitle.bold())
                .hAlign(Alignment.leading)
            
            Text("welcome back,\nYou have been missed")
                .font(.title)
                .hAlign(.leading)
            
            VStack(spacing: 12) {
                
                TextField("Email",text: $emailId)
                    .textContentType(UITextContentType.emailAddress)
                    .border(1, .gray.opacity(0.5))
                    .padding(.top,25)
                
                SecureField("Password", text: $password)
                    .textContentType(UITextContentType.password)
                    .border(1, .gray.opacity(0.5))
                
                Button("Reset password?",action: resetPassword)
                    .font(.callout)
                    .fontWeight(.medium)
                    .tint(.black)
                    .hAlign(.trailing)
                
                Button(action:loginUser) {
                    Text("Sign in")
                        .foregroundColor(.white)
                        .hAlign(.center)
                        .fillView(.black)
                }
                .padding(.top,10)
                
            }
            
            HStack {
                Text("Dont have an account?")
                    .foregroundColor(.gray)
                
                Button("Register Now"){
                    createAccount.toggle()
                }
                .fontWeight(.bold)
                .foregroundColor(.black)
            }
            .font(.callout)
            .vAlign(.bottom)
        }
        .vAlign(Alignment.top)
        .padding(15)
        .overlay(content: {
            LoadingView(show: $isLoading)
        })
        .fullScreenCover(isPresented: $createAccount) {
            RegisterView()
        }
        .alert(errorMessage,isPresented: $showError,actions: {})
        
    }
    func loginUser() {
        isLoading = true
        closeKeyboard()
        Task {
            do {
                try await Auth.auth().signIn(withEmail: emailId, password: password)
                print("User Found")
                try await fetchUser()
            }catch {
                await setError(error)
            }
        }
    }
    func fetchUser()async throws{
        guard let userID = Auth.auth().currentUser?.uid else {return}
        let a = try await Firestore.firestore().collection("Users").document(userID).getDocument(as: User.self)
        await MainActor.run(body: {
            userUID = userID
            userNameStored = a.userName
            profileURL = a.userProfileURL
            logStatus = true
        })
    }
    
    func setError(_ error: Error)async {
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showError.toggle()
            isLoading = false
        })
    }
    func resetPassword() {
        Task {
            do {
                try await Auth.auth().sendPasswordReset(withEmail: emailId)
                print("Resetted password")
                print("User Found")
            }catch {
                await setError(error)
            }
        }
        
    }
}


struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}



