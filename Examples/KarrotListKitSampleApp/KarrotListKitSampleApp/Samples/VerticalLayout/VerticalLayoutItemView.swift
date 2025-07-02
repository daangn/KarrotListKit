//
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import UIKit

import FlexLayout
import PinLayout

final class VerticalLayoutItemView: UIView {

  // MARK: ViewModel

  struct ViewModel: Equatable {

    let id: UUID
    var title: String?
    var subtitle: String?

    init(
      id: UUID = .init(),
      title: String? = nil,
      subtitle: String? = nil
    ) {
      self.id = id
      self.title = title
      self.subtitle = subtitle
    }

    static func random() -> Self {
      .init(
        title: .randomWords(count: .random(in: 4...10), wordLength: 4...10),
        subtitle: Bool.random() ? .randomWords(count: .random(in: 4...10), wordLength: 4...10) : nil
      )
    }
  }

  var viewModel: ViewModel {
    didSet {
      guard viewModel != oldValue else { return }
      applyViewModel()
    }
  }

  // MARK: Subviews

  private let rootFlexContainer = UIView()

  private let titleLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 0
    label.adjustsFontForContentSizeCategory = true
    label.font = .preferredFont(forTextStyle: .body)
    label.textColor = .label
    return label
  }()

  private let subtitleLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 0
    label.adjustsFontForContentSizeCategory = true
    label.font = .preferredFont(forTextStyle: .subheadline)
    label.textColor = .secondaryLabel
    return label
  }()

  private let separator: UIView = {
    let separator = UIView()
    separator.backgroundColor = .separator
    return separator
  }()

  // MARK: Init

  init(viewModel: ViewModel) {
    self.viewModel = viewModel
    super.init(frame: .zero)
    defineLayout()
    applyViewModel()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Configuration Methods

  private func defineLayout() {
    addSubview(rootFlexContainer)
    rootFlexContainer.flex
      .direction(.column)
      .paddingHorizontal(16.0)
      .paddingVertical(8.0)
      .define {
        $0.addItem(titleLabel)
        $0.addItem(subtitleLabel)
        $0.addItem(separator)
          .position(.absolute)
          .start(16.0)
          .end(0.0)
          .bottom(0.0)
          .height(1.0 / traitCollection.displayScale)
      }
  }

  private func applyViewModel() {
    titleLabel.text = viewModel.title
    subtitleLabel.text = viewModel.subtitle

    titleLabel.flex.markDirty()
    subtitleLabel.flex.markDirty()

    titleLabel.flex.display(viewModel.title != nil ? .flex : .none)
    subtitleLabel.flex.display(viewModel.subtitle != nil ? .flex : .none)
  }

  // MARK: UIView Methods

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    rootFlexContainer.flex.sizeThatFits(
      size: CGSize(
        width: size.width,
        height: .nan
      )
    )
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    rootFlexContainer.pin.all()
    rootFlexContainer.flex.layout()
  }

  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
      titleLabel.flex.markDirty()
      subtitleLabel.flex.markDirty()
    }
  }
}

@available(iOS 17.0, *)
#Preview {
  VerticalLayoutItemView(
    viewModel: .init(
      title: "Title",
      subtitle: "Subtitle"
    )
  )
}
