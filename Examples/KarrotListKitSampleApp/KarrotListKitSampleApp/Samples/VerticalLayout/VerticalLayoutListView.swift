//
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import UIKit

import KarrotListKit

final class VerticalLayoutListView: UIView {
  // MARK: Const

  private enum Const {
    static let pageSize = 100
    static let maximumViewModelCount = 1000
  }

  // MARK: UICollectionView

  private lazy var collectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewCompositionalLayout(
      sectionProvider: collectionViewAdapter.sectionLayout
    )
  )

  private let collectionViewAdapter = CollectionViewAdapter<CompositionalLayout>(
    configuration: CollectionViewAdapterConfiguration()
  )

  // MARK: ViewModel

  private var viewModels: [VerticalLayoutItemComponent.ViewModel] = [] {
    didSet {
      guard viewModels != oldValue else { return }
      applyViewModels()
    }
  }

  // MARK: Init

  override init(frame: CGRect) {
    super.init(frame: frame)
    collectionViewAdapter.register(collectionView: collectionView)
    defineLayout()
    resetViewModels()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Configuration Methods

  private func defineLayout() {
    backgroundColor = .systemGroupedBackground
    addSubview(collectionView)
  }

  private func resetViewModels() {
    viewModels = []
    appendViewModels()
  }

  private func appendViewModels() {
    guard viewModels.count < Const.maximumViewModelCount else { return }
    viewModels.append(contentsOf: (0 ..< Const.pageSize).map { _ in .random() })
  }

  private func applyViewModels() {
    collectionViewAdapter.apply(
      List {
        Section(id: "Section") {
          for viewModel in viewModels {
            Cell(
              id: viewModel.id,
              component: VerticalLayoutItemComponent(viewModel: viewModel)
            )
          }
        }
        .withHeader(SectionHeaderComponent(id: "header", title: "Vertical Layout"))
        .withFooter(SectionFooterComponent(id: "footer", text: "This is a vertical layout example with estimated item heights"))
        .withSectionLayout(
          VerticalLayout(
            itemHeightDimension: .estimated(80),
            headerHeightDimension: .estimated(56),
            footerHeightDimension: .estimated(40),
            spacing: 8
          )
          .supplementaryContentInsetsReference(.none)
          .makeSectionLayout()
        )
      }.onRefresh { [weak self] _ in
        self?.resetViewModels()
      }.onReachEnd(offsetFromEnd: .relativeToContainerSize(multiplier: 1.0)) { [weak self] _ in
        self?.appendViewModels()
      }
    )
  }

  // MARK: UIView Methods

  override func layoutSubviews() {
    super.layoutSubviews()
    collectionView.pin.all()
  }
}

@available(iOS 17.0, *)
#Preview {
  VerticalLayoutListView()
}
