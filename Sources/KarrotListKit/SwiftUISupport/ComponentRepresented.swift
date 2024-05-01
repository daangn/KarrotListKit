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

  func _overrideSizeThatFits(
    _ size: inout CGSize,
    in proposedSize: _ProposedSize,
    uiView: C.Content
  ) {
    size = uiView.sizeThatFits(
      CGSize(
        width: proposedSize.width ?? UIView.noIntrinsicMetric,
        height: proposedSize.height ?? UIView.noIntrinsicMetric
      )
    )
  }

#if swift(>=5.7)
  @available(iOS 16.0, *)
  func sizeThatFits(
    _ proposal: ProposedViewSize,
    uiView: C.Content,
    context: Context
  ) -> CGSize? {
    uiView.sizeThatFits(
      CGSize(
        width: proposal.width ?? UIView.noIntrinsicMetric,
        height: proposal.height ?? UIView.noIntrinsicMetric
      )
    )
  }
#endif
}

private extension SwiftUI._ProposedSize {

  var width: CGFloat? {
    Mirror(reflecting: self).children.first(where: { $0.label == "width" })?.value as? CGFloat
  }

  var height: CGFloat? {
    Mirror(reflecting: self).children.first(where: { $0.label == "height" })?.value as? CGFloat
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
