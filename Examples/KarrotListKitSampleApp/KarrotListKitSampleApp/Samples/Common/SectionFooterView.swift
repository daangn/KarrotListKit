//
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import UIKit

import FlexLayout
import PinLayout

final class SectionFooterView: UIView {
  // MARK: ViewModel
  
  struct ViewModel: Equatable {
    let text: String
    
    init(text: String) {
      self.text = text
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
  
  private let textLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 0
    label.adjustsFontForContentSizeCategory = true
    label.font = .systemFont(ofSize: 13)
    label.textColor = .secondaryLabel
    label.textAlignment = .center
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
    backgroundColor = .systemGroupedBackground
    
    addSubview(rootFlexContainer)
    rootFlexContainer.flex
      .direction(.row)
      .justifyContent(.center)
      .paddingHorizontal(16.0)
      .paddingTop(8.0)
      .paddingBottom(8.0)
      .define {
        $0.addItem(textLabel)
          .grow(1)
      }
  }
  
  private func applyViewModel() {
    textLabel.text = viewModel.text
    textLabel.flex.markDirty()
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
      textLabel.flex.markDirty()
      setNeedsLayout()
    }
  }
}

@available(iOS 17.0, *)
#Preview {
  SectionFooterView(
    viewModel: .init(text: "This is a sample footer text that explains what this section contains and provides additional context to the user.")
  )
}
