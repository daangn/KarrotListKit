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
    var iconColor: UInt32
    var iconName: String

    init(
      id: UUID = .init(),
      title: String? = nil,
      subtitle: String? = nil,
      iconColor: UInt32 = 0x000000,
      iconName: String = "star.fill"
    ) {
      self.id = id
      self.title = title
      self.subtitle = subtitle
      self.iconColor = iconColor
      self.iconName = iconName
    }

    static func random() -> Self {
      let icons = ["star.fill", "heart.fill", "bolt.fill", "flame.fill", "leaf.fill", "drop.fill", "snowflake", "sparkles"]
      let titles = ["Task Management", "Health Tracking", "Quick Actions", "Energy Monitor", "Eco Mode", "Water Reminder", "Winter Mode", "Magic Effects"]
      let subtitles = ["Organize your daily tasks", "Monitor your health metrics", "Access frequently used features", "Track energy consumption", "Save power and resources", "Stay hydrated throughout the day", "Optimized for cold weather", "Add special effects to photos"]
      let index = Int.random(in: 0 ..< icons.count)

      return .init(
        title: titles[index],
        subtitle: Bool.random() ? subtitles[index] : nil,
        iconColor: UInt32.random(in: 0x000000 ... 0xFFFFFF),
        iconName: icons[index]
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

  private let iconContainerView: UIView = {
    let view = UIView()
    view.layer.cornerRadius = 12
    view.layer.masksToBounds = true
    return view
  }()

  private let iconImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.tintColor = .white
    return imageView
  }()

  private let titleLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 2
    label.adjustsFontForContentSizeCategory = true
    label.font = .systemFont(ofSize: 16, weight: .semibold)
    label.textColor = .label
    return label
  }()

  private let subtitleLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 3
    label.adjustsFontForContentSizeCategory = true
    label.font = .systemFont(ofSize: 14)
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
    backgroundColor = .secondarySystemGroupedBackground
    layer.cornerRadius = 16
    layer.masksToBounds = true

    addSubview(rootFlexContainer)
    rootFlexContainer.addSubview(containerView)
    containerView.addSubview(iconContainerView)
    iconContainerView.addSubview(iconImageView)

    rootFlexContainer.flex
      .padding(4)
      .define {
        $0.addItem(containerView)
          .grow(1)
      }

    containerView.flex
      .direction(.row)
      .alignItems(.center)
      .paddingHorizontal(16.0)
      .paddingVertical(12.0)
      .define {
        $0.addItem(iconContainerView)
          .size(44)
          .marginEnd(12)

        $0.addItem()
          .direction(.column)
          .grow(1)
          .shrink(1)
          .define {
            $0.addItem(titleLabel)
            $0.addItem(subtitleLabel)
              .marginTop(2)
          }
      }

    iconImageView.flex
      .alignSelf(.center)
      .size(24)
  }

  private func applyViewModel() {
    titleLabel.text = viewModel.title
    subtitleLabel.text = viewModel.subtitle

    // Set icon
    iconImageView.image = UIImage(systemName: viewModel.iconName)

    // Convert UInt32 color to UIColor
    let red = CGFloat((viewModel.iconColor >> 16) & 0xFF) / 255.0
    let green = CGFloat((viewModel.iconColor >> 8) & 0xFF) / 255.0
    let blue = CGFloat(viewModel.iconColor & 0xFF) / 255.0
    iconContainerView.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)

    titleLabel.flex.markDirty()
    subtitleLabel.flex.markDirty()

    titleLabel.flex.display(viewModel.title != nil ? .flex : .none)
    subtitleLabel.flex.display(viewModel.subtitle != nil ? .flex : .none)

    setNeedsLayout()
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
      iconImageView.flex.markDirty()
      setNeedsLayout()
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
