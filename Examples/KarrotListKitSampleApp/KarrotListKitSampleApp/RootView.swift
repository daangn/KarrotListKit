//
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import SwiftUI

struct RootView: View {
  var body: some View {
    NavigationStack {
      List {
        NavigationLink("VerticalLayout") {
          UIViewRepresentation { _ in
            VerticalLayoutListView()
          }
          .ignoresSafeArea()
          .navigationTitle("VerticalLayout")
          .navigationBarTitleDisplayMode(.inline)
        }
        
        NavigationLink("HorizontalLayout") {
          UIViewRepresentation { _ in
            HorizontalLayoutListView()
          }
          .ignoresSafeArea()
          .navigationTitle("HorizontalLayout")
          .navigationBarTitleDisplayMode(.inline)
        }
        
        NavigationLink("VerticalGridLayout") {
          UIViewRepresentation { _ in
            VerticalGridLayoutListView()
          }
          .ignoresSafeArea()
          .navigationTitle("VerticalGridLayout")
          .navigationBarTitleDisplayMode(.inline)
        }
      }
      .navigationTitle("KarrotListKit")
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}

#Preview {
  RootView()
}
