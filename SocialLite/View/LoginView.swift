//
//  LoginView.swift
//  SocialLite
//
//  Created by Tei on 14/3/21.
//

import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var appState: AppState
    
    @State var email = ""
    @State var password = ""
    
    var body: some View {
        VStack {
            TextField("Email", text: self.$email)
            SecureField("Password", text: self.$password)
            Button("Sign In") {
                // TODO: implement this
                self.appState.currentUser = User(key: "TESTING_KEY", uid: "TESTING_KEY", displayName: "TESTING", email: "test@test.com")
            }
            NavigationLink(destination: SignUpView()) {
                Text("Sign Up")
            }
        }
        .navigationBarItems(leading: EmptyView(), trailing: EmptyView())
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
