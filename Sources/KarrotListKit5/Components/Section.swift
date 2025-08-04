public struct Section<Layout: CollectionLayout> {

  public let id: AnyHashable
  public let items: [Item<Layout>]
  public let supplementaryItems: [ElementKind: [any SupplementaryItemProtocol]]
  public let decorationItems: [ElementKind: [any DecorationItemProtocol]]
  public var layoutValues: Layout.SectionLayoutValues

  public init(
    id: some Hashable,
    items: [Item<Layout>],
    supplementaryItems: [ElementKind: [any SupplementaryItemProtocol]],
    decorationItems: [ElementKind: [any DecorationItemProtocol]],
    layoutValues: Layout.SectionLayoutValues
  ) {
    self.id = id
    self.items = items
    self.supplementaryItems = supplementaryItems
    self.decorationItems = decorationItems
    self.layoutValues = layoutValues
  }
}
