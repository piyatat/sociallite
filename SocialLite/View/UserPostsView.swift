//
//  UserPostsView.swift
//  SocialLite
//
//  Created by Tei on 15/3/21.
//

import SwiftUI

struct UserPostsView: View {
    
    @EnvironmentObject var appState: AppState
    
    @State private var showPostOption = false
    @State private var selectedItem: Post?
    
    var body: some View {
        
        let hasError: Binding<Bool> = Binding<Bool> { () -> Bool in
            return self.appState.userItemsFetchError != nil
        } set: { (visible) in
            if !visible {
                self.appState.userItemsFetchError = nil
            }
        }
        
        return GeometryReader { georeader in
            RefreshableScrollView { (completion) in
                // Reload items
                if let userID = self.appState.selectedUserID {
                    self.appState.dbManager?.fetchUserPosts(for: userID, startAfter: nil)
                }
                completion()
            } content: {
                VStack {
                    if let userID = self.appState.selectedUserID,
                       let items = self.appState.userItems[userID], items.count > 0
                    {
                        LazyVStack {
                            ForEach(0..<items.count, id: \.self) { i in
                                // Item row
                                VStack (alignment: .leading) {
                                    // Header
                                    HStack {
                                        UserInfoCellHeader(userID: items[i].uid).environmentObject(self.appState)

                                        if self.appState.currentUserID == items[i].uid {
                                            Button {
                                                // Show post option for this post
                                                self.selectedItem = items[i]
                                                self.showPostOption.toggle()
                                            } label: {
                                                Image(systemName: "ellipsis")
                                                    .font(.subheadline)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                    
                                    // Content
                                    Text("\(self.appState.items[i].text)")
                                        .font(.body)
                                        .padding(.vertical)
                                    
                                    // Footer
                                    Text("\(Date.stringFromTimeInterval(TimeInterval(self.appState.items[i].time)))")
                                        .font(.footnote)
                                }
                                .padding()
                                
                                Divider()
                                    .background(Color("DividerColor"))
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.bottom)
                    } else {
                        Text("No Post to Display")
                            .font(.subheadline)
                            .padding()
                    }
                    
                    if self.appState.hasMoreUserPost {
                        Button(action: {
                            // Consume more state
                            self.appState.hasMoreUserPost = false
                            // Load more items
                            if let userID = self.appState.selectedUserID,
                               let lastItem = self.appState.items.last
                            {
                                self.appState.dbManager?.fetchUserPosts(for: userID, startAfter: lastItem)
                            }
                        }, label: {
                            Text("Load More ...")
                                .font(.footnote)
                        })
                        .buttonStyle(PlainButtonStyle())
                        .padding(.bottom, georeader.safeAreaInsets.bottom + 10)
                    }
                }
            }
            .frame(width: georeader.size.width)
            .background(Color("BGColor"))
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarTitle(Text("\(self.appState.selectedUserID != nil ? (self.appState.getUser(self.appState.selectedUserID!)?.displayName ?? "Loading ...") : "Loading ...")"), displayMode: .inline)
            .alert(isPresented: hasError) {
                // There is an error, show error message (if no message, show default error message)
                Alert(title: Text("Error"), message: Text("\(self.appState.userItemsFetchError?.localizedDescription ?? "Something worng, please try again!")"), dismissButton: .default(Text("OK")))
            }
            .actionSheet(isPresented: self.$showPostOption) {
                ActionSheet(title: Text("Post Options"), buttons: [
                    .default(Text("Remove this post"), action: {
                        // Remove selected item
                        if let item = self.selectedItem {
                            self.appState.dbManager?.deletePost(item)
                        }
                        self.selectedItem = nil
                    }),
                    .cancel()
                ])
            }
        }
        .onAppear {
            // Fetch user posts
            if let userID = self.appState.selectedUserID {
                self.appState.dbManager?.fetchUserPosts(for: userID, startAfter: nil)
            }
        }
    }
}

struct UserPostsView_Previews: PreviewProvider {
    static var previews: some View {
        let appState = AppState()
        let auth = DummyAuthManager()
        auth.config()
        let db = DummyDBManager()
        db.config()
        appState.config(auth: auth, db: db)
        appState.selectedUserID = "DemoUser@toremove.com"
        
        return Group {
            NavigationView {
                UserPostsView()
                    .environmentObject(appState)
                    .preferredColorScheme(.light)
            }
            NavigationView {
                UserPostsView()
                    .environmentObject(appState)
                    .preferredColorScheme(.dark)
            }
        }
    }
}
