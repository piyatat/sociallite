//
//  TimelineView.swift
//  SocialLite
//
//  Created by Tei on 14/3/21.
//

import SwiftUI

struct TimelineView: View {
    
    @EnvironmentObject var appState: AppState
    
    @State private var showNewPost = false
    
    var body: some View {
        VStack {
            List {
                ForEach(0..<10, id: \.self) { i in
                    NavigationLink(destination: UserPostsView().environmentObject(self.appState)) {
                        Text("Item - \(i+1)")
                    }
                }
            }
            .navigationBarTitle(Text("Timeline"))
            .navigationBarItems(leading: Button(action: {
                self.appState.currentUser = nil
            }, label: {
                Text("Logout")
            }), trailing: NavigationLink(destination: NewPostView().environmentObject(self.appState), label: {
                Text("New")
            }))
        }
    }
}

struct TimelineView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineView()
    }
}
