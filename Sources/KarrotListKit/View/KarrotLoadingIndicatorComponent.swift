//
//  Copyright (c) 2024 Danggeun Market Inc.
//

import UIKit

public struct KarrotLoadingIndicatorComponent: Component {

  public let viewModel: KarrotLoadingIndicatorView.ViewModel

  public var layoutMode: ContentLayoutMode {
    viewModel.layoutMode
  }

  public init(viewModel: KarrotLoadingIndicatorView.ViewModel) {
    self.viewModel = viewModel
  }

  public func renderContent(coordinator: ()) -> KarrotLoadingIndicatorView {
    KarrotLoadingIndicatorView(viewModel: viewModel)
  }

  public func render(in content: KarrotLoadingIndicatorView, coordinator: ()) {
    content.startAnimating()
  }
}
