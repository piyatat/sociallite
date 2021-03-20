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
    
    init() {
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithTransparentBackground()
        coloredAppearance.backgroundColor = UIColor(named: "NavBarColor")
        coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
        UINavigationBar.appearance().tintColor = .white
    }
    
    var body: some View {
        
        let hasError: Binding<Bool> = Binding<Bool> { () -> Bool in
            return (self.appState.itemCreatedError != nil)
                || (self.appState.itemFetchError != nil)
                || (self.appState.itemsFetchError != nil)
                || (self.appState.itemRemovedError != nil)
        } set: { (visible) in
            if !visible {
                self.appState.itemCreatedError = nil
                self.appState.itemFetchError = nil
                self.appState.itemsFetchError = nil
                self.appState.itemRemovedError = nil
            }
        }
        
        return GeometryReader { georeader in
            RefreshableScrollView { (completion) in
                // Reload items
                self.appState.dbManager?.fetchPosts(startAfter: nil)
                completion()
            } content: {
                VStack {
                    LazyVStack {
                        ForEach(0..<self.appState.items.count, id: \.self) { i in
                            // Item cell
                            ItemCell(item: self.appState.items[i]).environmentObject(self.appState)
                                .padding()
                            
                            Divider()
                                .background(Color("DividerColor"))
                                .padding(.horizontal)
                        }
                    }
                    .padding(.bottom)
                    
                    if self.appState.hasMorePost {
                        Button(action: {
                            // Consume more state
                            self.appState.hasMorePost = false
                            // Load more items
                            if let lastItem = self.appState.items.last {
                                self.appState.dbManager?.fetchPosts(startAfter: lastItem)
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
            .background(Color("BGColor"))
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarTitle(Text("Timeline"), displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                self.appState.currentUserID = nil
            }, label: {
                Text("Logout")
                    .font(.headline)
            }), trailing: Button(action: {
                self.showNewPost.toggle()
            }, label: {
                Image(systemName: "rectangle.badge.plus")
                    .font(.title)
            }))
            .sheet(isPresented: self.$showNewPost, onDismiss: {
                self.showNewPost = false
            }) {
                NewPostView().environmentObject(self.appState)
            }
            .alert(isPresented: hasError) {
                // There is an error, show error message (if no message, show default error message)
                Alert(title: Text("Error"),
                      message: Text("\(self.appState.itemCreatedError?.localizedDescription ?? self.appState.itemFetchError?.localizedDescription ?? self.appState.itemsFetchError?.localizedDescription ?? self.appState.itemRemovedError?.localizedDescription ?? "Something worng, please try again!")"), dismissButton: .default(Text("OK")))
            }
        }
    }
}

struct TimelineView_Previews: PreviewProvider {
    static var previews: some View {
        let appState = AppState()
        let auth = DummyAuthManager()
        auth.config()
        let db = DummyDBManager()
        db.config()
        appState.config(auth: auth, db: db)
        
        return Group {
            NavigationView {
                TimelineView()
                    .environmentObject(appState)
                    .preferredColorScheme(.light)
            }
            NavigationView {
                TimelineView()
                    .environmentObject(appState)
                    .preferredColorScheme(.dark)
            }
        }
    }
}
