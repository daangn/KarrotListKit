import KarrotListKit

struct SectionFooterComponent: Component {
  
  typealias ViewModel = SectionFooterView.ViewModel
  
  let viewModel: ViewModel
  
  init(id: AnyHashable, text: String) {
    self.viewModel = ViewModel(text: text)
  }
  
  func renderContent(coordinator: ()) -> SectionFooterView {
    SectionFooterView(
      viewModel: viewModel
    )
  }
  
  func render(in content: SectionFooterView, coordinator: ()) {
    content.viewModel = viewModel
  }
}