//
//  UserInfoCellHeader.swift
//  SocialLite
//
//  Created by Tei on 17/3/21.
//

import SwiftUI

struct UserInfoCellHeader: View {
    
    @EnvironmentObject var appState: AppState
    
    var userID: String
    
    var body: some View {
        HStack {
            Image(systemName: "person.crop.circle")
                .font(.largeTitle)
            VStack (alignment: .leading) {
                // Get user from cache
                if let user = self.appState.getUser(self.userID) {
                    Text("\(user.displayName)")
                        .font(.subheadline)
                    Text("\(user.email)")
                        .font(.caption)
                } else {
                    // Not cache yet, show loading text
                    Text("Loading ...")
                        .font(.subheadline)
                    Text("Loading ...")
                        .font(.caption)
                }
            }
            Spacer()
        }
    }
}

struct UserInfoCellHeader_Previews: PreviewProvider {
    static var previews: some View {
        let appState = AppState()
        
        return Group {
            UserInfoCellHeader(userID: "MOCKUP_UID")
                .environmentObject(appState)
                .preferredColorScheme(.light)
            UserInfoCellHeader(userID: "MOCKUP_UID")
                .environmentObject(appState)
                .preferredColorScheme(.dark)
        }
    }
}
