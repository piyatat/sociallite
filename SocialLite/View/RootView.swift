//
//  RootView.swift
//  SocialLite
//
//  Created by Tei on 14/3/21.
//

import SwiftUI

struct RootView: View {
    
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        if let _ = self.appState.currentUserID {
            NavigationView {
                TimelineView()
                    .environmentObject(self.appState)
            }
        } else {
            LoginView()
                .environmentObject(self.appState)
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        let appState = AppState()
        
        RootView().environmentObject(appState)
    }
}
