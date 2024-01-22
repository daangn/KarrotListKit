//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import UIKit

public protocol Component {
  associatedtype ViewModel: Equatable

  associatedtype Content: UIView

  associatedtype Coordinator = Void

  var viewModel: ViewModel { get }

  var reuseIdentifier: String { get }

  var layoutMode: ContentLayoutMode { get }

  func renderContent(coordinator: Coordinator) -> Content

  func render(in content: Content, coordinator: Coordinator)

  func layout(content: Content, in container: UIView)

  func makeCoordinator() -> Coordinator
}

extension Component {
  public var reuseIdentifier: String {
    String(reflecting: Self.self)
  }
}

extension Component where Coordinator == Void {
  public func makeCoordinator() -> Coordinator {
    ()
  }
}

extension Component where Content: UIView {
  public func layout(content: Content, in container: UIView) {
    content.translatesAutoresizingMaskIntoConstraints = false
    container.addSubview(content)
    NSLayoutConstraint.activate([
      content.topAnchor.constraint(equalTo: container.topAnchor),
      content.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      content.bottomAnchor.constraint(equalTo: container.bottomAnchor),
      content.trailingAnchor.constraint(equalTo: container.trailingAnchor),
    ])
  }
}
