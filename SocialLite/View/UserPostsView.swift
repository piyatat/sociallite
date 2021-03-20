//
//  UserPostsView.swift
//  SocialLite
//
//  Created by Tei on 15/3/21.
//

import SwiftUI

struct UserPostsView: View {
    
    @EnvironmentObject var appState: AppState
    
    var userID: String
    
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
                self.appState.dbManager?.fetchUserPosts(for: self.userID, startAfter: nil)
                completion()
            } content: {
                VStack {
                    if let items = self.appState.userItems[self.userID] {
                        LazyVStack {
                            ForEach(0..<items.count, id: \.self) { i in
                                // Item cell
                                ItemCell(item: items[i]).environmentObject(self.appState)
                                    .padding()
                                
                                Divider()
                                    .background(Color("DividerColor"))
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.bottom)
                    }
                    
                    if self.appState.hasMoreUserPost {
                        Button(action: {
                            // Consume more state
                            self.appState.hasMoreUserPost = false
                            // Load more items
                            if let lastItem = self.appState.items.last {
                                self.appState.dbManager?.fetchUserPosts(for: self.userID, startAfter: lastItem)
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
            .navigationBarTitle(Text("\(self.appState.getUser(self.userID)?.displayName ?? "Loading ...")"), displayMode: .inline)
            .alert(isPresented: hasError) {
                // There is an error, show error message (if no message, show default error message)
                Alert(title: Text("Error"), message: Text("\(self.appState.userItemsFetchError?.localizedDescription ?? "Something worng, please try again!")"), dismissButton: .default(Text("OK")))
            }
        }
        .onAppear {
            // Fetch user posts
            self.appState.dbManager?.fetchUserPosts(for: self.userID, startAfter: nil)
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
        
        return Group {
            NavigationView {
                UserPostsView(userID: "DemoUser@toremove.com")
                    .environmentObject(appState)
                    .preferredColorScheme(.light)
            }
            NavigationView {
                UserPostsView(userID: "DemoUser@toremove.com")
                    .environmentObject(appState)
                    .preferredColorScheme(.dark)
            }
        }
    }
}
