import KarrotListKit

struct SectionHeaderComponent: Component {
  typealias ViewModel = SectionHeaderView.ViewModel
  
  let viewModel: ViewModel
  
  init(id: AnyHashable, title: String) {
    self.viewModel = ViewModel(title: title)
  }
  
  func renderContent(coordinator: ()) -> SectionHeaderView {
    SectionHeaderView(
      viewModel: viewModel
    )
  }
  
  func render(in content: SectionHeaderView, coordinator: ()) {
    content.viewModel = viewModel
  }
}
