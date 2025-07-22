//
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import KarrotListKit

struct VerticalGridLayoutItemComponent: Component {
  typealias ViewModel = VerticalGridLayoutItemView.ViewModel

  let viewModel: ViewModel

  init(viewModel: ViewModel) {
    self.viewModel = viewModel
  }

  func renderContent(coordinator: ()) -> VerticalGridLayoutItemView {
    VerticalGridLayoutItemView(
      viewModel: viewModel
    )
  }

  func render(in content: VerticalGridLayoutItemView, coordinator: ()) {
    content.viewModel = viewModel
  }
}
