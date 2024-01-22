//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import UIKit

final class UICollectionComponentReusableView: UICollectionReusableView, ComponentRenderable {

  var renderedContent: UIView?

  var coordinator: Any?

  var renderedComponent: AnyComponent?

  var onSizeChanged: ((CGSize) -> Void)?

  // MARK: - Initializing

  @available(*, unavailable)
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override init(frame: CGRect) {
    super.init(frame: frame)

    backgroundColor = .clear
  }

  // MARK: - Override Methods

  public override func preferredLayoutAttributesFitting(
    _ layoutAttributes: UICollectionViewLayoutAttributes
  ) -> UICollectionViewLayoutAttributes {
    let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)

    guard let renderedContent else {
      return attributes
    }

    let size = renderedContent.sizeThatFits(bounds.size)

    if renderedComponent != nil {
      onSizeChanged?(size)
    }

    return attributes.with {
      $0.frame.size = size
    }
  }
}
