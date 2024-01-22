//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import Combine
import UIKit

final class UICollectionViewComponentCell: UICollectionViewCell, ComponentRenderable {

  var renderedContent: UIView?

  var coordinator: Any?

  var renderedComponent: AnyComponent?

  var cancellables: [AnyCancellable]?

  var onSizeChanged: ((CGSize) -> Void)?

  // MARK: - Initializing

  @available(*, unavailable)
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override init(frame: CGRect) {
    super.init(frame: frame)

    backgroundColor = .clear
    contentView.backgroundColor = .clear
  }

  deinit {
    cancellables?.forEach { $0.cancel() }
  }

  // MARK: - Override Methods

  override func prepareForReuse() {
    super.prepareForReuse()

    cancellables?.forEach { $0.cancel() }
  }

  public override func preferredLayoutAttributesFitting(
    _ layoutAttributes: UICollectionViewLayoutAttributes
  ) -> UICollectionViewLayoutAttributes {
    let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)

    guard let renderedContent else {
      return attributes
    }

    let size = renderedContent.sizeThatFits(contentView.bounds.size)

    if renderedComponent != nil {
      onSizeChanged?(size)
    }

    return attributes.with {
      $0.frame.size = size
    }
  }
}
