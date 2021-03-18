//
//  SignUpView.swift
//  SocialLite
//
//  Created by Tei on 14/3/21.
//

import SwiftUI

struct SignUpView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appState: AppState
    
    @State private var email = ""
    @State private var password = ""
    @State private var displayName = ""
    
    var body: some View {
        
        let hasError: Binding<Bool> = Binding<Bool> { () -> Bool in
            return self.appState.signUpError != nil
        } set: { (visible) in
            if !visible {
                self.appState.signUpError = nil
            }
        }
        
        return GeometryReader { georeader in
            VStack {
                HStack {
                    Button("Cancel") {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding()
                }
                .frame(width: georeader.size.width, alignment: .leading)
                
                Spacer()
                    .frame(height: 20)
                
                HStack {
                    Text("Email")
                        .font(.headline)
                    TextField("Enter Email Address", text: self.$email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.body)
                }
                .padding()
                
                HStack {
                    Text("Display Name")
                        .font(.headline)
                    TextField("Enter Display Name", text: self.$displayName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.body)
                }
                .padding()
                
                HStack {
                    Text("Password")
                        .font(.headline)
                    SecureField("Enter Password", text: self.$password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.body)
                }
                .padding()
                
                Button("Sign Up") {
                    // Sign Up Action
                    self.appState.authManager?.signUp(email: self.email, password: self.password, displayName: self.displayName)
                }
                .font(.headline)
                .foregroundColor(.blue)
                .frame(width: georeader.size.width * 0.5)
                .padding(.vertical, 8)
                .buttonStyle(DefaultButtonStyle())
                .background(Color.init(white: 0.9))
                .cornerRadius(10.0)
                
                Spacer()
            }
            .background(Color("BGColor"))
            .ignoresSafeArea()
        }
        .alert(isPresented: hasError) {
            // There is an error, show error message (if no message, show default error message)
            Alert(title: Text("Error"), message: Text("\(self.appState.signUpError?.localizedDescription ?? "Something worng, please try again!")"), dismissButton: .default(Text("OK")))
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SignUpView()
                .previewDevice("iPhone 12 Pro Max")
                .preferredColorScheme(.light)
            SignUpView()
                .previewDevice("iPhone 12 Pro Max")
                .preferredColorScheme(.dark)
            SignUpView()
                .previewDevice("iPhone SE (2nd generation)")
                .preferredColorScheme(.light)
        }
    }
}
