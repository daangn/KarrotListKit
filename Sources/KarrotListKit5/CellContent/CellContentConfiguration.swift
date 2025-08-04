//
//  CellContentConfiguration.swift
//  KarrotListKit
//
//  Created by Max.kim on 7/24/25.
//

import UIKit

public struct CellContentConfiguration<Content: CellContentRepresentable>: UIContentConfiguration {

  let content: Content

  public func makeContentView() -> any UIView & UIContentView {
    CellContentHostingView(configuration: self)
  }

  public func updated(for state: any UIConfigurationState) -> Self {
    return self
  }
}

final class CellContentHostingView<Content: CellContentRepresentable>: UICollectionReusableView, UIContentView {

  typealias ContentConfiguration = CellContentConfiguration<Content>

  var contentConfiguration: ContentConfiguration {
    didSet {
      applyConfiguration()
    }
  }

  var configuration: any UIContentConfiguration {
    get {
      contentConfiguration
    }
    set {
      guard let configuration = newValue as? ContentConfiguration else { return }
      contentConfiguration = configuration
    }
  }

  private let coordinator: Content.Coordinator
  private let uiView: Content.UIViewType

  private var context: Content.Context {
    .init(coordinator: coordinator)
  }

  init(configuration contentConfiguration: ContentConfiguration) {
    self.contentConfiguration = contentConfiguration
    self.coordinator = contentConfiguration.content.makeCoordinator()
    self.uiView = contentConfiguration.content.makeUIView(context: .init(coordinator: coordinator))
    super.init(frame: .zero)
    applyConfiguration()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func applyConfiguration() {
    contentConfiguration.content.updateUIView(uiView, context: context)
  }

  override func preferredLayoutAttributesFitting(
    _ layoutAttributes: UICollectionViewLayoutAttributes
  ) -> UICollectionViewLayoutAttributes {
    contentConfiguration.content.preferredLayoutAttributesFitting(
      layoutAttributes,
      uiView: uiView,
      context: context
    )
  }
}
