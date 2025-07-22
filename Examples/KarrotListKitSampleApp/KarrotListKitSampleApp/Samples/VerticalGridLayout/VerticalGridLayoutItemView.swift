//
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import UIKit

import FlexLayout
import PinLayout

final class VerticalGridLayoutItemView: UIView {
  // MARK: ViewModel

  struct ViewModel: Equatable {
    let id: UUID
    let emoji: String
    let title: String
    let color: UInt32

    init(
      id: UUID = .init(),
      emoji: String,
      title: String,
      color: UInt32
    ) {
      self.id = id
      self.emoji = emoji
      self.title = title
      self.color = color
    }

    static func random() -> Self {
      let emojis = ["🍎", "🍊", "🍋", "🍌", "🍉", "🍇", "🍓", "🫐", "🍈", "🍒", "🍑", "🥭", "🍍", "🥥", "🥝"]
      let titles = ["Apple", "Orange", "Lemon", "Banana", "Watermelon", "Grape", "Strawberry", "Blueberry", "Melon", "Cherry", "Peach", "Mango", "Pineapple", "Coconut", "Kiwi"]
      let index = Int.random(in: 0 ..< emojis.count)

      return Self(
        emoji: emojis[index],
        title: titles[index],
        color: UInt32.random(in: 0x000000 ... 0xFFFFFF)
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

  private let emojiLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 40)
    label.textAlignment = .center
    label.adjustsFontForContentSizeCategory = true
    return label
  }()

  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 13, weight: .medium)
    label.textAlignment = .center
    label.textColor = .white
    label.numberOfLines = 1
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

    containerView.layer.cornerRadius = 12
    containerView.layer.masksToBounds = true

    rootFlexContainer.flex
      .padding(4)
      .define {
        $0.addItem(containerView)
          .grow(1)
      }

    containerView.flex
      .direction(.column)
      .alignItems(.center)
      .justifyContent(.center)
      .paddingHorizontal(8)
      .paddingVertical(8)
      .define {
        $0.addItem(emojiLabel)
        $0.addItem(titleLabel)
          .marginTop(4)
          .width(100%)
      }
  }

  private func applyViewModel() {
    emojiLabel.text = viewModel.emoji
    titleLabel.text = viewModel.title

    // Convert UInt32 color to UIColor with reduced opacity
    let red = CGFloat((viewModel.color >> 16) & 0xFF) / 255.0
    let green = CGFloat((viewModel.color >> 8) & 0xFF) / 255.0
    let blue = CGFloat(viewModel.color & 0xFF) / 255.0
    containerView.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 0.8)

    emojiLabel.flex.markDirty()
    titleLabel.flex.markDirty()

    setNeedsLayout()
  }

  // MARK: UIView Methods

  override func sizeThatFits(_ size: CGSize) -> CGSize {
    rootFlexContainer.flex.sizeThatFits(
      size: CGSize(
        width: size.width,
        height: size.width // Square aspect ratio for grid items
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
      emojiLabel.flex.markDirty()
      titleLabel.flex.markDirty()
      setNeedsLayout()
    }
  }
}

@available(iOS 17.0, *)
#Preview {
  VerticalGridLayoutItemView(
    viewModel: .init(
      emoji: "🍎",
      title: "Apple",
      color: 0xFF5733
    )
  )
}
