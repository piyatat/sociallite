//
//  ItemCell.swift
//  SocialLite
//
//  Created by Tei on 20/3/21.
//

import SwiftUI

struct ItemCell: View {
    
    @EnvironmentObject var appState: AppState
    
    @State private var showPostOption = false
    
    var item: Post
    
    var body: some View {
        VStack (alignment: .leading) {
            // Header
            HStack {
                NavigationLink(
                    destination: UserPostsView(userID: self.item.uid).environmentObject(self.appState),
                    label: {
                        UserInfoCellHeader(userID: self.item.uid).environmentObject(self.appState)
                    })
                    .buttonStyle(PlainButtonStyle())
                
                if self.appState.currentUserID == self.item.uid {
                    Button {
                        // Show post option for this post
                        self.showPostOption.toggle()
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.subheadline)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            // Content
            Text("\(self.item.text)")
                .font(.body)
                .padding(.vertical)
            
            // Footer
            Text("\(Date.stringFromTimeInterval(TimeInterval(self.item.time)))")
                .font(.footnote)
        }
        .actionSheet(isPresented: self.$showPostOption) {
            ActionSheet(title: Text("Post Options"), buttons: [
                .default(Text("Remove this post"), action: {
                    // Remove selected item
                    self.appState.dbManager?.deletePost(self.item)
                }),
                .cancel()
            ])
        }
    }
}

struct ItemCell_Previews: PreviewProvider {
    static var previews: some View {
        let appState = AppState()
        let item = Post(key: "ItemID", text: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.", time: Int(Date.timeIntervalSinceReferenceDate), uid: "DemoUser@toremove.com")
        
        return Group {
            ItemCell(item: item)
                .environmentObject(appState)
                .preferredColorScheme(.light)
            ItemCell(item: item)
                .environmentObject(appState)
                .preferredColorScheme(.dark)
        }
    }
}
