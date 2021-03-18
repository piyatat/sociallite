//
//  LoginView.swift
//  SocialLite
//
//  Created by Tei on 14/3/21.
//

import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var appState: AppState
    
    @State var showSignUpView = false
    @State var email = ""
    @State var password = ""
    
    var body: some View {
        
        let hasError: Binding<Bool> = Binding<Bool> { () -> Bool in
            return self.appState.signInError != nil
        } set: { (visible) in
            if !visible {
                self.appState.signInError = nil
            }
        }
        
        return GeometryReader { georeader in
            VStack {
                Spacer()
                
                Image("Apple")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: georeader.size.width * 0.6)
                
                HStack {
                    Text("Email")
                        .font(.headline)
                    TextField("Enter Email Address", text: self.$email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.body)
                }
                .padding(.horizontal)
                
                HStack {
                    Text("Password")
                        .font(.headline)
                    SecureField("Enter Password", text: self.$password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.body)
                }
                .padding(.horizontal)
                
                Button("Sign In") {
                    // Sign in
                    self.appState.authManager?.signIn(email: self.email, password: self.password)
                }
                .font(.headline)
                .foregroundColor(.blue)
                .frame(width: georeader.size.width * 0.5)
                .padding(.vertical)
                .buttonStyle(DefaultButtonStyle())
                .background(Color.init(white: 0.9))
                .cornerRadius(10.0)
                .padding(.vertical)
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button("Sign Up") {
                        self.showSignUpView.toggle()
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding()
                    .buttonStyle(PlainButtonStyle())
                }
                .padding()
            }
            .background(Color("BGColor"))
            .ignoresSafeArea()
            .sheet(isPresented: self.$showSignUpView, content: {
                SignUpView().environmentObject(self.appState)
            })
            .alert(isPresented: hasError) {
                // There is an error, show error message (if no message, show default error message)
                Alert(title: Text("Error"), message: Text("\(self.appState.signInError?.localizedDescription ?? "Something worng, please try again!")"), dismissButton: .default(Text("OK")))
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoginView()
                .previewDevice("iPhone 12 Pro Max")
                .preferredColorScheme(.light)
            LoginView()
                .previewDevice("iPhone 12 Pro Max")
                .preferredColorScheme(.dark)
            LoginView()
                .previewDevice("iPhone SE (2nd generation)")
        }
    }
}
