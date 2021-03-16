//
//  UserPostsView.swift
//  SocialLite
//
//  Created by Tei on 15/3/21.
//

import SwiftUI

struct UserPostsView: View {
    
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        GeometryReader { georeader in
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
            .navigationBarTitle(Text("User Name"), displayMode: .inline)
        }
    }
}

struct UserPostsView_Previews: PreviewProvider {
    static var previews: some View {
        let appState = AppState()
        
        NavigationView {
            UserPostsView()
                .environmentObject(appState)
                .previewDevice("iPhone 12 Pro Max")
                .preferredColorScheme(.light)
        }
        NavigationView {
            UserPostsView()
                .environmentObject(appState)
                .previewDevice("iPhone 12 Pro Max")
                .preferredColorScheme(.dark)
        }
        NavigationView {
            UserPostsView()
                .environmentObject(appState)
                .previewDevice("iPhone SE (2nd generation)")
        }
    }
}
