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
        GeometryReader { georeader in
            ZStack {
                ScrollView {
                    LazyVStack {
                        ForEach(0..<10, id: \.self) { i in
                            VStack (alignment: .leading) {
                                NavigationLink(
                                    destination: UserPostsView().environmentObject(self.appState),
                                    label: {
                                        HStack {
                                            Image(systemName: "person.crop.circle")
                                                .font(.largeTitle)
                                            VStack (alignment: .leading) {
                                                Text("Display Name")
                                                    .font(.subheadline)
                                                Text("Email")
                                                    .font(.caption)
                                            }
                                            Spacer()
                                        }
                                    })
                                    .buttonStyle(PlainButtonStyle())
                                Text("Post Detail")
                                    .font(.body)
                                    .padding(.vertical)
                                Text("Time")
                                    .font(.footnote)
                            }
                            .padding()
                            
                            Divider()
                                .background(Color("DividerColor"))
                                .padding(.horizontal)
                        }
                    }
                    .padding(.bottom)
                    
                    Button(action: {
                        // TODO: implement this
                        // Load More action
                    }, label: {
                        Text("Load More ...")
                            .font(.footnote)
                    })
                    .buttonStyle(PlainButtonStyle())
                    .padding(.bottom, georeader.safeAreaInsets.bottom + 10)
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
                
                VStack {
                    Button(action: {
                        // TODO: implement this
                        // Reload action
                    }, label: {
                        Text("New Post, Tap to reload")
                    })
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding()
                    .buttonStyle(DefaultButtonStyle())
                    .background(Color.init(white: 0.9))
                    .cornerRadius(30.0)
                    .padding(.vertical)
                    .opacity(0.8)
                    
                    Spacer()
                }
            }
        }
    }
}

struct TimelineView_Previews: PreviewProvider {
    static var previews: some View {
        let appState = AppState()
        
        NavigationView {
            TimelineView()
                .environmentObject(appState)
                .previewDevice("iPhone 12 Pro Max")
                .preferredColorScheme(.light)
        }
        NavigationView {
            TimelineView()
                .environmentObject(appState)
                .previewDevice("iPhone 12 Pro Max")
                .preferredColorScheme(.dark)
        }
        NavigationView {
            TimelineView()
                .environmentObject(appState)
                .previewDevice("iPhone SE (2nd generation)")
        }
    }
}
