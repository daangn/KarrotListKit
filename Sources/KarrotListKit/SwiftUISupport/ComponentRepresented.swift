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
  public func toSwiftUI() -> some View {
    ComponentRepresented(component: self)
  }
}
