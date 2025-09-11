//
//  Copyright (c) 2024 Danggeun Market Inc.
//

#if canImport(UIKit)
import UIKit

final class UICollectionComponentReusableView: UICollectionReusableView, ComponentRenderable {

  var renderedContent: UIView?

  var coordinator: Any?

  var renderedComponent: AnyComponent?

  var onSizeChanged: ((CGSize) -> Void)?

  private var previousBounds: CGSize = .zero

  // MARK: - Initializing

  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    backgroundColor = .clear
  }

  // MARK: - Override Methods

  public override func traitCollectionDidChange(
    _ previousTraitCollection: UITraitCollection?
  ) {
    super.traitCollectionDidChange(previousTraitCollection)

    if shouldInvalidateContentSize(
      previousTraitCollection: previousTraitCollection
    ) {
      previousBounds = .zero
    }
  }

  public override func prepareForReuse() {
    super.prepareForReuse()

    previousBounds = .zero
  }

  public override func layoutSubviews() {
    super.layoutSubviews()

    previousBounds = bounds.size
  }

  override func preferredLayoutAttributesFitting(
    _ layoutAttributes: UICollectionViewLayoutAttributes
  ) -> UICollectionViewLayoutAttributes {
    let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)

    guard let renderedContent else {
      return attributes
    }

    if KarrotListKitFeatureFlag.provider.isEnabled(for: .usesCachedViewSize),
       previousBounds == attributes.size {
      return attributes
    }

    let size = renderedContent.sizeThatFits(bounds.size)

    if renderedComponent != nil {
      onSizeChanged?(size)
    }

    attributes.frame.size = size

    return attributes
  }
}
#endif
