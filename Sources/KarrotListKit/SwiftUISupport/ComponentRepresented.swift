//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import SwiftUI

struct ComponentRepresented<C: Component>: UIViewRepresentable {
  private let component: C

  init(component: C) {
    self.component = component
  }

  func makeUIView(context: Context) -> C.Content {
    component.renderContent(coordinator: context.coordinator)
  }

  func updateUIView(_ uiView: C.Content, context: Context) {
    component.render(in: uiView, coordinator: context.coordinator)
  }

  func makeCoordinator() -> C.Coordinator {
    component.makeCoordinator()
  }
}

extension Component {
  /// This helper method allows the Component to be used in SwiftUI.
  ///
  /// Component has an API similar to UIViewRepresentable.
  /// By using this method, you can easily migrate to SwiftUI.
  public func toSwiftUI() -> some View {
    ComponentRepresented(component: self)
  }
}
