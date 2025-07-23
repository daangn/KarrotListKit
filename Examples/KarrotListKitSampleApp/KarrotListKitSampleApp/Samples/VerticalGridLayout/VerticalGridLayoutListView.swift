//
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import UIKit

import KarrotListKit

final class VerticalGridLayoutListView: UIView {
  // MARK: Const

  private enum Const {
    static let pageSize = 30
    static let maximumViewModelCount = 300
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

  private var gridItems: [VerticalGridLayoutItemComponent.ViewModel] = [] {
    didSet {
      guard gridItems != oldValue else { return }
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
    gridItems = []
    appendViewModels()
  }

  private func appendViewModels() {
    guard gridItems.count < Const.maximumViewModelCount else { return }
    gridItems.append(contentsOf: (0 ..< Const.pageSize).map { _ in .random() })
  }

  private func applyViewModels() {
    collectionViewAdapter.apply(
      List {
        // 2-column grid section
        Section(id: "grid-2-columns") {
          for (index, item) in gridItems.prefix(12).enumerated() {
            Cell(
              id: "\(item.id)-2col-\(index)",
              component: VerticalGridLayoutItemComponent(viewModel: item)
            )
          }
        }
        .withHeader(SectionHeaderComponent(id: "grid-2-header", title: "2-Column Grid"))
        .withFooter(SectionFooterComponent(id: "grid-2-footer", text: "Grid layout with 2 items per row"))
        .withSectionLayout(
          VerticalGridLayout(
            numberOfItemsInRow: 2,
            itemHeightDimension: .estimated(120),
            headerHeightDimension: .estimated(56),
            footerHeightDimension: .estimated(40),
            interItemSpacing: 8,
            interGroupSpacing: 8
          )
          .insets(NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
          .supplementaryContentInsetsReference(.none)
          .makeSectionLayout()
        )

        // 3-column grid section
        Section(id: "grid-3-columns") {
          for (index, item) in gridItems.dropFirst(12).prefix(18).enumerated() {
            Cell(
              id: "\(item.id)-3col-\(index)",
              component: VerticalGridLayoutItemComponent(viewModel: item)
            )
          }
        }
        .withHeader(SectionHeaderComponent(id: "grid-3-header", title: "3-Column Grid"))
        .withFooter(SectionFooterComponent(id: "grid-3-footer", text: "Grid layout with 3 items per row"))
        .withSectionLayout(
          VerticalGridLayout(
            numberOfItemsInRow: 3,
            itemHeightDimension: .estimated(100),
            headerHeightDimension: .estimated(56),
            footerHeightDimension: .estimated(40),
            interItemSpacing: 8,
            interGroupSpacing: 8
          )
          .insets(NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
          .supplementaryContentInsetsReference(.none)
          .makeSectionLayout()
        )

        // 4-column grid section
        Section(id: "grid-4-columns") {
          for (index, item) in gridItems.dropFirst(30).enumerated() {
            Cell(
              id: "\(item.id)-4col-\(index)",
              component: VerticalGridLayoutItemComponent(viewModel: item)
            )
          }
        }
        .withHeader(SectionHeaderComponent(id: "grid-4-header", title: "4-Column Grid"))
        .withFooter(SectionFooterComponent(id: "grid-4-footer", text: "Grid layout with 4 items per row - pull to refresh or scroll to load more"))
        .withSectionLayout(
          VerticalGridLayout(
            numberOfItemsInRow: 4,
            itemHeightDimension: .estimated(80),
            headerHeightDimension: .estimated(56),
            footerHeightDimension: .estimated(60),
            interItemSpacing: 8,
            interGroupSpacing: 8
          )
          .insets(NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
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
  VerticalGridLayoutListView()
}
