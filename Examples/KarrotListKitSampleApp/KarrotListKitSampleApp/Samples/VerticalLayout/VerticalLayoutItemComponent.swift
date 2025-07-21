//
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import KarrotListKit

struct VerticalLayoutItemComponent: Component {

  typealias ViewModel = VerticalLayoutItemView.ViewModel

  let viewModel: ViewModel

  init(viewModel: ViewModel) {
    self.viewModel = viewModel
  }

  func renderContent(coordinator: ()) -> VerticalLayoutItemView {
    VerticalLayoutItemView(
      viewModel: viewModel
    )
  }

  func render(in content: VerticalLayoutItemView, coordinator: ()) {
    content.viewModel = viewModel
  }
}
