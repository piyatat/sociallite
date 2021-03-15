//
//  NewPostView.swift
//  SocialLite
//
//  Created by Tei on 15/3/21.
//

import SwiftUI

struct NewPostView: View {
    
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Text("New Post View")
    }
}

struct NewPostView_Previews: PreviewProvider {
    static var previews: some View {
        NewPostView()
    }
}
