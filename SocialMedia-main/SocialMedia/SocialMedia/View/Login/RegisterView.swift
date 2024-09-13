//
//  RegisterView.swift
//  SocialMedia
//
//  Created by Aditya Inamdar on 16/02/23.
//

import SwiftUI
import PhotosUI
import FirebaseFirestoreSwift
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

struct RegisterView: View {
    
    @State var emailId: String = ""
    @State var password: String = ""
    @State var userName: String = ""
    @State var userBio: String = ""
    @State var userBioLink: String = ""
    @State var userProfilePicData: Data?
    
    @Environment(\.dismiss) var dismiss
    @State var showImagePicker:Bool = false
    @State var photoItem: PhotosPickerItem?
    @State var errorMessage: String = ""
    @State var showError:Bool = false
    @State var isLoading: Bool = false
    
    @AppStorage("log_status") var logStatus: Bool = false
    @AppStorage("user_profile_url") var profileURL: URL?
    @AppStorage("user_name") var userNameStored: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    
    
    var body: some View {
        
        VStack(spacing:10){
            
            Text("Lets Register\nAccount")
                .font(.largeTitle.bold())
                .hAlign(Alignment.leading)
            
            Text("Hello user, have a wonderful journey")
                .font(.title3)
                .hAlign(.leading)
            
            ViewThatFits {
                ScrollView(.vertical,showsIndicators: false) {
                    HelperView()
                }
                HelperView()
            }
            
            HStack {
                Text("Already have an account")
                    .foregroundColor(.gray)
                
                Button("Login Now"){
                    dismiss()
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
        .photosPicker(isPresented: $showImagePicker, selection: $photoItem)
        .onChange(of: photoItem) { newValue in
            if let newValue {
                Task {
                    do {
                        guard let imageData = try await newValue.loadTransferable(type: Data.self) else {return}
                        await MainActor.run(body: { userProfilePicData = imageData })
                    }catch {
                        print("error setting profile img: \(error.localizedDescription)")
                    }
                }
            }
        }
        .alert(errorMessage, isPresented: $showError, actions: {})
        
    }
    @ViewBuilder
    func HelperView()->some View {
        VStack(spacing: 12) {
            ZStack{
                if let userProfilePicData,let image = UIImage(data: userProfilePicData){
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
                else {
                    Image("nullProfilePic")
                        .resizable()
                        .aspectRatio( contentMode: .fill)
                }
            }
            .frame(width: 85,height: 95)
            .clipShape(Circle())
            .contentShape(Circle())
            .onTapGesture {
                showImagePicker.toggle()
            }
            .padding(.top,25)
            
            TextField("Username",text: $userName)
                .textContentType(UITextContentType.username)
                .border(1, .gray.opacity(0.5))
                .padding(.top,25)
            
            TextField("Email",text: $emailId)
                .textContentType(UITextContentType.emailAddress)
                .border(1, .gray.opacity(0.5))
            
            SecureField("Password", text: $password)
                .textContentType(UITextContentType.password)
                .border(1, .gray.opacity(0.5))
            
            TextField("About You",text: $userBio,axis: .vertical)
                .frame(minHeight: 100,alignment: .top)
                .textContentType(UITextContentType.emailAddress)
                .border(1, .gray.opacity(0.5))
            
            TextField("Bio Link (Optional)",text: $userBioLink)
                .textContentType(UITextContentType.emailAddress)
                .border(1, .gray.opacity(0.5))
            
            
            
            Button(action: registerUser) {
                Text("Sign up")
                    .foregroundColor(.white)
                    .hAlign(.center)
                    .fillView(.black)
            }
            .disableWithOpacity(userName == "" || userBio == "" || emailId == "" || password == "" || userProfilePicData == nil)
            .padding(.top,10)
        }
    }
    
    func registerUser() {
        isLoading = true
        closeKeyboard()
        Task {
            do {
                try await Auth.auth().createUser(withEmail: emailId, password: password)
                guard let userUID = Auth.auth().currentUser?.uid else {return}
                guard let imageData = userProfilePicData else {return}
                let storageRef = Storage.storage().reference().child("Profile_Images").child(userUID)
               let _ = try await storageRef.putDataAsync(imageData)
                let downloadURL = try await storageRef.downloadURL()
                let user = User(userName: userName, userBio: userBio, userBioLink: userBioLink, userUID: userUID, userEmail: emailId, userProfileURL: downloadURL)
               
                let _ = try Firestore.firestore().collection("Users").document(userUID).setData(from: user,completion: { error in
                    if error == nil {
                        print("Saved Successfully")
                        userNameStored = userName
                        self.userUID = userUID
                        self.profileURL = downloadURL
                        self.logStatus = true
                    }
                })
                
            } catch {
                await setError(error)
            }
        }
    }
    
    func setError(_ error: Error)async {
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showError.toggle()
            isLoading = false
        })
    }
    
    
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
