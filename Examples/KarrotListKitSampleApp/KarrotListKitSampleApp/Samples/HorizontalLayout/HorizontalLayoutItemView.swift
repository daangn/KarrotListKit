//
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import UIKit

import FlexLayout
import PinLayout

final class HorizontalLayoutItemView: UIView {
  // MARK: ViewModel

  struct ViewModel: Equatable {
    let id: UUID
    let title: String
    let imageColor: UInt32

    init(
      id: UUID = .init(),
      title: String,
      imageColor: UInt32
    ) {
      self.id = id
      self.title = title
      self.imageColor = imageColor
    }

    static func random() -> Self {
      .init(
        title: [
          "Apple", "Banana", "Cherry", "Date", "Elderberry",
          "Fig", "Grape", "Honeydew", "Kiwi", "Lemon"
        ].randomElement()!,
        imageColor: UInt32.random(in: 0x000000 ... 0xFFFFFF)
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

  private let containerView = UIView()

  private let imageView: UIView = {
    let view = UIView()
    view.layer.cornerRadius = 8
    view.layer.masksToBounds = true
    return view
  }()

  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 14, weight: .medium)
    label.textAlignment = .center
    label.numberOfLines = 2
    label.adjustsFontForContentSizeCategory = true
    return label
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
    rootFlexContainer.addSubview(containerView)

    containerView.backgroundColor = .secondarySystemGroupedBackground
    containerView.layer.cornerRadius = 12
    containerView.layer.masksToBounds = true

    rootFlexContainer.flex
      .padding(4)
      .define {
        $0.addItem(containerView)
          .width(120)
          .grow(1)
      }

    containerView.flex
      .direction(.column)
      .alignItems(.center)
      .paddingTop(12)
      .paddingBottom(12)
      .paddingHorizontal(8)
      .define {
        $0.addItem(imageView)
          .size(80)
        $0.addItem(titleLabel)
          .marginTop(8)
          .width(100%)
      }
  }

  private func applyViewModel() {
    titleLabel.text = viewModel.title

    // Convert UInt32 color to UIColor
    let red = CGFloat((viewModel.imageColor >> 16) & 0xFF) / 255.0
    let green = CGFloat((viewModel.imageColor >> 8) & 0xFF) / 255.0
    let blue = CGFloat(viewModel.imageColor & 0xFF) / 255.0
    imageView.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)

    titleLabel.flex.markDirty()

    setNeedsLayout()
  }

  // MARK: UIView Methods

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    rootFlexContainer.flex.sizeThatFits(
      size: CGSize(
        width: 128,
        height: CGFloat.nan
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
      setNeedsLayout()
    }
  }
}

@available(iOS 17.0, *)
#Preview {
  HorizontalLayoutItemView(
    viewModel: .init(
      title: "Sample Item",
      imageColor: 0xFF5733
    )
  )
}
