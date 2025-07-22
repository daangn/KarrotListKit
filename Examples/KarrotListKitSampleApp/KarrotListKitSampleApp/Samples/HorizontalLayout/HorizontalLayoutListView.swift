//
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import UIKit

import KarrotListKit

final class HorizontalLayoutListView: UIView {
  // MARK: UICollectionView

  private let layoutAdapter = CollectionViewLayoutAdapter()

  private lazy var collectionView = UICollectionView(layoutAdapter: layoutAdapter)

  private lazy var collectionViewAdapter = CollectionViewAdapter(
    configuration: CollectionViewAdapterConfiguration(),
    collectionView: collectionView,
    layoutAdapter: layoutAdapter
  )

  // MARK: ViewModel

  private var continuousItems: [HorizontalLayoutItemComponent.ViewModel] = []
  private var groupPagingItems: [HorizontalLayoutItemComponent.ViewModel] = []

  // MARK: Init

  override init(frame: CGRect) {
    super.init(frame: frame)
    defineLayout()
    generateViewModels()
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

  private func generateViewModels() {
    // Generate items for continuous scrolling
    continuousItems = (0..<20).map { _ in .random() }

    // Generate items for group paging
    groupPagingItems = (0..<12).map { _ in .random() }

    applyViewModels()
  }

  private func applyViewModels() {
    collectionViewAdapter.apply(
      List {
        // Continuous horizontal scrolling section
        Section(id: "continuous-section") {
          for item in continuousItems {
            Cell(
              id: item.id,
              component: HorizontalLayoutItemComponent(viewModel: item)
            )
          }
        }
        .withHeader(SectionHeaderComponent(id: "continuous-header", title: "Continuous Scrolling"))
        .withFooter(SectionFooterComponent(id: "continuous-footer", text: "Smooth continuous horizontal scrolling"))
        .withSectionLayout(
          HorizontalLayout.horizontalLayout(
            itemSize: NSCollectionLayoutSize(
              widthDimension: .estimated(120),
              heightDimension: .estimated(140)
            ),
            headerSize: NSCollectionLayoutSize(
              widthDimension: .fractionalWidth(1.0),
              heightDimension: .estimated(56)
            ),
            footerSize: NSCollectionLayoutSize(
              widthDimension: .fractionalWidth(1.0),
              heightDimension: .estimated(40)
            ),
            spacing: 8,
            scrollingBehavior: .continuous
          )
          .supplementaryContentInsetsReference(.none)
        )

        // Group paging section - pages by groups of items
        Section(id: "group-paging-section") {
          for item in groupPagingItems {
            Cell(
              id: item.id,
              component: HorizontalLayoutItemComponent(viewModel: item)
            )
          }
        }
        .withHeader(SectionHeaderComponent(id: "group-paging-header", title: "Group Paging"))
        .withFooter(SectionFooterComponent(id: "group-paging-footer", text: "Pages through groups of items that fit the screen"))
        .withSectionLayout(
          HorizontalLayout.horizontalLayout(
            itemSize: NSCollectionLayoutSize(
              widthDimension: .estimated(110),
              heightDimension: .estimated(140)
            ),
            headerSize: NSCollectionLayoutSize(
              widthDimension: .fractionalWidth(1.0),
              heightDimension: .estimated(56)
            ),
            footerSize: NSCollectionLayoutSize(
              widthDimension: .fractionalWidth(1.0),
              heightDimension: .estimated(40)
            ),
            spacing: 8,
            scrollingBehavior: .groupPaging
          )
          .supplementaryContentInsetsReference(.none)
        )
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
  HorizontalLayoutListView()
}
