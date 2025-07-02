//
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import SwiftUI

struct UIViewRepresentation<
  UIViewType: UIView,
  Coordinator
>: UIViewRepresentable {

  private let _makeCoordinator: () -> Coordinator
  private let _makeUIView: (_ context: Context) -> UIViewType
  private let _updateUIView: (_ uiView: UIViewType, _ context: Context) -> Void
  private let _sizeThatFits: (
    _ proposal: ProposedViewSize,
    _ uiView: UIViewType,
    _ context: Context
  ) -> CGSize?

  init(
    makeCoordinator: @escaping () -> Coordinator = { () },
    makeUIView: @escaping (_ context: Context) -> UIViewType,
    updateUIView: @escaping (_ uiView: UIViewType, _ context: Context) -> Void = { _, _ in },
    sizeThatFits: @escaping (
      _ proposal: ProposedViewSize,
      _ uiView: UIViewType,
      _ context: Context
    ) -> CGSize? = { _, _, _ in nil }
  ) {
    self._makeCoordinator = makeCoordinator
    self._makeUIView = makeUIView
    self._updateUIView = updateUIView
    self._sizeThatFits = sizeThatFits
  }

  func makeCoordinator() -> Coordinator {
    _makeCoordinator()
  }

  func makeUIView(context: Context) -> UIViewType {
    _makeUIView(context)
  }

  func updateUIView(_ uiView: UIViewType, context: Context) {
    _updateUIView(uiView, context)
  }

  func sizeThatFits(
    _ proposal: ProposedViewSize,
    uiView: UIViewType,
    context: Context
  ) -> CGSize? {
    _sizeThatFits(proposal, uiView, context)
  }
}
