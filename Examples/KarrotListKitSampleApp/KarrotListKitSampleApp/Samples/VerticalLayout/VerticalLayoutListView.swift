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

  private let layoutAdapter = CollectionViewLayoutAdapter()

  private lazy var collectionView = UICollectionView(layoutAdapter: layoutAdapter)

  private lazy var collectionViewAdapter = CollectionViewAdapter(
    configuration: CollectionViewAdapterConfiguration(),
    collectionView: collectionView,
    layoutAdapter: layoutAdapter
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
    defineLayout()
    resetViewModels()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Configuration Methods

  private func defineLayout() {
    addSubview(collectionView)
  }

  private func resetViewModels() {
    viewModels = []
    appendViewModels()
  }

  private func appendViewModels() {
    guard viewModels.count < Const.maximumViewModelCount else { return }
    viewModels.append(contentsOf: (0..<Const.pageSize).map { _ in .random() })
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
        .withSectionLayout { context in
          let size = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44.0)
          )
          let item = NSCollectionLayoutItem(
            layoutSize: size
          )
          let group = NSCollectionLayoutGroup.vertical(
            layoutSize: size,
            subitems: [item]
          )

          return NSCollectionLayoutSection(group: group)
        }
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
