//
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import UIKit

import FlexLayout
import PinLayout

final class SectionHeaderView: UIView {
  // MARK: ViewModel
  
  struct ViewModel: Equatable {
    let title: String
    
    init(title: String) {
      self.title = title
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
    label.numberOfLines = 1
    label.adjustsFontForContentSizeCategory = true
    label.font = .systemFont(ofSize: 20, weight: .semibold)
    label.textColor = .label
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
      .alignItems(.center)
      .paddingHorizontal(16.0)
      .paddingTop(12.0)
      .paddingBottom(12.0)
      .define {
        $0.addItem(titleLabel)
      }
  }
  
  private func applyViewModel() {
    titleLabel.text = viewModel.title
    titleLabel.flex.markDirty()
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
      setNeedsLayout()
    }
  }
}

@available(iOS 17.0, *)
#Preview {
  SectionHeaderView(
    viewModel: .init(title: "Sample Section Header")
  )
}
