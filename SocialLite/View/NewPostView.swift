//
//  NewPostView.swift
//  SocialLite
//
//  Created by Tei on 15/3/21.
//

import SwiftUI

struct NewPostView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appState: AppState
    
    @State var postText = ""
    
    var body: some View {
        GeometryReader { georeader in
            VStack {
                HStack {
                    Button("Cancel") {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding()
                    
                    Spacer()
                    
                    Button("Post") {
                        // Create new post action
                        if let userID = self.appState.currentUserID {
                            self.appState.dbManager?.createPost(self.postText, userID: userID)
                        }
                        // Dismiss this view
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding()
                }
                .frame(width: georeader.size.width, alignment: .leading)
                
                Spacer()
                    .frame(height: 20)
                
                TextEditor(text: self.$postText)
                    .cornerRadius(10.0)
                    .font(.body)
                    .padding()
                
                Spacer()
            }
            .background(Color("BGColor"))
            .ignoresSafeArea()
        }
    }
}

struct NewPostView_Previews: PreviewProvider {
    static var previews: some View {
        let appState = AppState()
        let auth = DummyAuthManager()
        auth.config()
        let db = DummyDBManager()
        db.config()
        appState.config(auth: auth, db: db)
        
        return Group {
            NewPostView()
                .environmentObject(appState)
                .preferredColorScheme(.light)
            NewPostView()
                .environmentObject(appState)
                .preferredColorScheme(.dark)
        }
    }
}
