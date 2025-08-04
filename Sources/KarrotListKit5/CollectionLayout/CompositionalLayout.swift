import UIKit

public struct CompositionalLayout: CollectionLayout {

  public static func makeCollectionViewLayout(
    list: List<Self>
  ) -> UICollectionViewCompositionalLayout {
    list.layoutValues.makeLayoutSection(list: list)
  }

  public struct LayoutValues {
    let _makeCollectionViewLayout: (
      _ list: List<CompositionalLayout>
    ) -> UICollectionViewCompositionalLayout
    let configuration: UICollectionViewCompositionalLayoutConfiguration

    func makeLayoutSection(list: List<CompositionalLayout>) -> UICollectionViewCompositionalLayout {
      let layout = _makeCollectionViewLayout(list)
      layout.configuration = configuration
      return layout
    }
  }

  public struct SectionLayoutValues {
    let _makeLayoutSection: (_ layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection
    var configurationHandlers: [(NSCollectionLayoutSection) -> Void] = []

    func makeLayoutSection(layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
      let layoutSection = _makeLayoutSection(layoutEnvironment)
      for handler in configurationHandlers {
        handler(layoutSection)
      }
      return layoutSection
    }
  }

  public struct BoundarySupplementaryItemLayoutValues {
    let _makeLayoutItem: (_ elementKind: ElementKind) -> NSCollectionLayoutBoundarySupplementaryItem
    var configurationHandlers: [(NSCollectionLayoutBoundarySupplementaryItem) -> Void] = []

    func makeLayoutItem(with elementKind: ElementKind) -> NSCollectionLayoutBoundarySupplementaryItem {
      let layoutItem = _makeLayoutItem(elementKind)
      for handler in configurationHandlers {
        handler(layoutItem)
      }
      return layoutItem
    }
  }

  public struct DecorationItemLayoutValues {
    let _makeLayoutItem: (_ elementKind: ElementKind) -> NSCollectionLayoutDecorationItem
    var configurationHandlers: [(NSCollectionLayoutDecorationItem) -> Void] = []

    func makeLayoutItem(with elementKind: ElementKind) -> NSCollectionLayoutDecorationItem {
      let layoutItem = _makeLayoutItem(elementKind)
      for handler in configurationHandlers {
        handler(layoutItem)
      }
      return layoutItem
    }
  }
}

extension List<CompositionalLayout> {

  private init(
    makeCollectionViewLayout: @escaping (
      _ list: List<CompositionalLayout>
    ) -> UICollectionViewCompositionalLayout,
    sections: [Section<Layout>],
    boundarySupplementaryItems: [ElementKindGroup<SupplementaryItem<CompositionalLayout.BoundarySupplementaryItemLayoutValues>>]
  ) {
    let boundarySupplementaryItemsByElementKind = Dictionary(
      boundarySupplementaryItems,
      key: \.elementKind,
      uniquingKeysWith: { _, new in new }
    ).mapValues(\.items)
    let layoutBoundarySupplementaryItems = boundarySupplementaryItems.flatMap { group in
      group.items.map { $0.layoutValues.makeLayoutItem(with: group.elementKind) }
    }
    self.init(
      sections: sections,
      supplementaryItems: boundarySupplementaryItemsByElementKind,
      layoutValues: .init(
        _makeCollectionViewLayout: makeCollectionViewLayout,
        configuration: {
          let configuration = UICollectionViewCompositionalLayoutConfiguration()
          configuration.boundarySupplementaryItems = layoutBoundarySupplementaryItems
          return configuration
        }()
      )
    )
  }

  public init(
    @SectionsBuilder<Layout> sections: () -> [Section<Layout>],
    @ElementKindGroupsBuilder<SupplementaryItem<CompositionalLayout.BoundarySupplementaryItemLayoutValues>> boundarySupplementaryItems: () -> [ElementKindGroup<SupplementaryItem<CompositionalLayout.BoundarySupplementaryItemLayoutValues>>] = { [] }
  ) {
    self.init(
      makeCollectionViewLayout: { list in
        UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
          // FIXME: safe subscript 처리 필요
          list.sections[sectionIndex].layoutValues.makeLayoutSection(layoutEnvironment: layoutEnvironment)
        }
      },
      sections: sections(),
      boundarySupplementaryItems: boundarySupplementaryItems()
    )
  }

  public static func list(
    using configuration: UICollectionLayoutListConfiguration,
    @SectionsBuilder<Layout> sections: () -> [Section<Layout>],
    @ElementKindGroupsBuilder<SupplementaryItem<CompositionalLayout.BoundarySupplementaryItemLayoutValues>> boundarySupplementaryItems: () -> [ElementKindGroup<SupplementaryItem<CompositionalLayout.BoundarySupplementaryItemLayoutValues>>] = { [] }
  ) -> Self {
    return self.init(
      makeCollectionViewLayout: { _ in
        UICollectionViewCompositionalLayout.list(using: configuration)
      },
      sections: sections(),
      boundarySupplementaryItems: boundarySupplementaryItems()
    )
  }
}

extension Section<CompositionalLayout> {

  private init(
    id: some Hashable,
    items: [Item<Layout>],
    boundarySupplementaryItems: [ElementKindGroup<SupplementaryItem<CompositionalLayout.BoundarySupplementaryItemLayoutValues>>],
    decorationItems: [ElementKindGroup<DecorationItem<CompositionalLayout.DecorationItemLayoutValues>>],
    makeLayoutSection: @escaping (_ layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection
  ) {
    let boundarySupplementaryItemsByElementKind = Dictionary(
      boundarySupplementaryItems,
      key: \.elementKind,
      uniquingKeysWith: { _, new in new }
    ).mapValues(\.items)
    let decorationItemsByElementKind = Dictionary(
      decorationItems,
      key: \.elementKind,
      uniquingKeysWith: { _, new in new }
    ).mapValues(\.items)

    let layoutBoundarySupplementaryItems = boundarySupplementaryItems.flatMap { group in
      group.items.map { $0.layoutValues.makeLayoutItem(with: group.elementKind) }
    }
    let layoutDecorationItems = decorationItems.flatMap { group in
      group.items.map { $0.layoutValues.makeLayoutItem(with: group.elementKind) }
    }

    self.init(
      id: id,
      items: items,
      supplementaryItems: boundarySupplementaryItemsByElementKind,
      decorationItems: decorationItemsByElementKind,
      layoutValues: .init(
        _makeLayoutSection: makeLayoutSection,
        configurationHandlers: [
          { $0.boundarySupplementaryItems = layoutBoundarySupplementaryItems },
          { $0.decorationItems = layoutDecorationItems },
        ]
      )
    )
  }

  public init(
    id: some Hashable,
    group: NSCollectionLayoutGroup,
    @ItemsBuilder<Layout> items: () -> [Item<Layout>],
    @ElementKindGroupsBuilder<SupplementaryItem<CompositionalLayout.BoundarySupplementaryItemLayoutValues>> boundarySupplementaryItems: () -> [ElementKindGroup<SupplementaryItem<CompositionalLayout.BoundarySupplementaryItemLayoutValues>>] = { [] },
    @ElementKindGroupsBuilder<DecorationItem<CompositionalLayout.DecorationItemLayoutValues>> decorationItems: () -> [ElementKindGroup<DecorationItem<CompositionalLayout.DecorationItemLayoutValues>>] = { [] }
  ) {
    self.init(
      id: id,
      items: items(),
      boundarySupplementaryItems: boundarySupplementaryItems(),
      decorationItems: decorationItems(),
      makeLayoutSection: { _ in
        NSCollectionLayoutSection(group: group)
      }
    )
  }

  public static func list(
    id: some Hashable,
    using configuration: UICollectionLayoutListConfiguration,
    @ItemsBuilder<Layout> items: () -> [Item<Layout>],
    @ElementKindGroupsBuilder<SupplementaryItem<CompositionalLayout.BoundarySupplementaryItemLayoutValues>> boundarySupplementaryItems: () -> [ElementKindGroup<SupplementaryItem<CompositionalLayout.BoundarySupplementaryItemLayoutValues>>] = { [] },
    @ElementKindGroupsBuilder<DecorationItem<CompositionalLayout.DecorationItemLayoutValues>> decorationItems: () -> [ElementKindGroup<DecorationItem<CompositionalLayout.DecorationItemLayoutValues>>] = { [] }
  ) -> Self {
    return self.init(
      id: id,
      items: items(),
      boundarySupplementaryItems: boundarySupplementaryItems(),
      decorationItems: decorationItems(),
      makeLayoutSection: { layoutEnvironment in
        NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
      }
    )
  }
}

extension SupplementaryItem<CompositionalLayout.BoundarySupplementaryItemLayoutValues> {

  public init<ContentConfigurationType: UIContentConfiguration>(
    layoutSize: NSCollectionLayoutSize,
    alignment: NSRectAlignment,
    contentConfiguration: () -> ContentConfigurationType
  ) {
    self.reuseIdentifier = String(describing: ContentConfigurationType.self)
    self.contentConfiguration = contentConfiguration()
    self.layoutValues = .init(
      _makeLayoutItem: { elementKind in
        return .init(
          layoutSize: layoutSize,
          elementKind: elementKind.rawValue,
          alignment: alignment
        )
      }
    )
  }

  public init<ContentConfigurationType: UIContentConfiguration>(
    layoutSize: NSCollectionLayoutSize,
    alignment: NSRectAlignment,
    absoluteOffset: CGPoint,
    contentConfiguration: () -> ContentConfigurationType
  ) {
    self.reuseIdentifier = String(describing: ContentConfigurationType.self)
    self.contentConfiguration = contentConfiguration()
    self.layoutValues = .init(
      _makeLayoutItem: { elementKind in
        return .init(
          layoutSize: layoutSize,
          elementKind: elementKind.rawValue,
          alignment: alignment,
          absoluteOffset: absoluteOffset
        )
      }
    )
  }
}

extension DecorationItem<CompositionalLayout.DecorationItemLayoutValues> {

  public static func background<ViewClass: UICollectionReusableView>(
    viewClass: ViewClass.Type
  ) -> Self {
    return self.init(
      viewClass: viewClass,
      layoutValues: .init(
        _makeLayoutItem: { elementKind in
          return .background(elementKind: elementKind.rawValue)
        }
      )
    )
  }
}
