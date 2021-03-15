//
//  SignUpView.swift
//  SocialLite
//
//  Created by Tei on 14/3/21.
//

import SwiftUI

struct SignUpView: View {
    
    @State private var email = ""
    @State private var password = ""
    @State private var displayName = ""
    
    var body: some View {
        VStack {
            HStack {
                Text("Email")
                TextField("Enter Email Address", text: $email)
            }
            .padding()
            
            HStack {
                Text("Display Name")
                TextField("Enter Display Name", text: $displayName)
            }
            .padding()
            
            HStack {
                Text("Password")
                TextField("Enter Password", text: $password)
            }
            .padding()
            
            Button("Sign Up") {
                // Sign Up Action
            }
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
