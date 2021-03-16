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
                        // TODO: implement this
                        // Create new post action
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
                    .aspectRatio(contentMode: .fit)
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
        NewPostView()
            .previewDevice("iPhone 12 Pro Max")
            .preferredColorScheme(.light)
        NewPostView()
            .previewDevice("iPhone 12 Pro Max")
            .preferredColorScheme(.dark)
        NewPostView()
            .previewDevice("iPhone SE (2nd generation)")
            .preferredColorScheme(.light)
    }
}
