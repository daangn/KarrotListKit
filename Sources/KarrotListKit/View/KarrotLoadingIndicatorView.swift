//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import UIKit

public final class KarrotLoadingIndicatorView: UIView {
  public struct ViewModel: Equatable {
    public let color: UIColor
    public let style: UIActivityIndicatorView.Style
    public let layoutMode: ContentLayoutMode

    public init(
      color: UIColor,
      style: UIActivityIndicatorView.Style = .medium,
      layoutMode: ContentLayoutMode = .flexibleHeight(estimatedHeight: 44.0)
    ) {
      self.color = color
      self.style = style
      self.layoutMode = layoutMode
    }
  }

  private let container = UIView()

  private let indicatorView = UIActivityIndicatorView()

  private let viewModel: ViewModel

  init(viewModel: ViewModel) {
    self.viewModel = viewModel

    super.init(frame: .zero)

    addSubview(container)

    indicatorView.translatesAutoresizingMaskIntoConstraints = false
    indicatorView.color = viewModel.color
    indicatorView.style = viewModel.style

    container.addSubview(indicatorView)
    NSLayoutConstraint.activate([
      indicatorView.topAnchor.constraint(equalTo: container.topAnchor),
      indicatorView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      indicatorView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
      indicatorView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
    ])
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func startAnimating() {
    indicatorView.startAnimating()
  }

  public func stopAnimating() {
    indicatorView.stopAnimating()
  }

  public override func layoutSubviews() {
    container.frame = bounds
  }

  public override func sizeThatFits(_ size: CGSize) -> CGSize {
    switch viewModel.layoutMode {
    case .flexibleHeight(let estimatedHeight):
      container.frame.size = .init(width: size.width, height: estimatedHeight)
    case .flexibleWidth(let estimatedWidth):
      container.frame.size = .init(width: estimatedWidth, height: size.height)
    case .fitContent(let estimatedSize):
      container.frame.size = estimatedSize
    case .fitContainer:
      container.frame.size = size
    }

    return container.frame.size
  }
}
