import UIKit

struct ListValues {
  var targetContentOffsetForProposedContentOffset: ((_ collectionView: UICollectionView, _ proposedContentOffset: CGPoint) -> CGPoint)?
}

public struct List<Layout: CollectionLayout> {

  public let sections: [Section<Layout>]
  public let supplementaryItems: [ElementKind: [any SupplementaryItemProtocol]]

  public var layoutValues: Layout.LayoutValues
  var values: ListValues = .init()

  public init(
    sections: [Section<Layout>],
    supplementaryItems: [ElementKind: [any SupplementaryItemProtocol]],
    layoutValues: Layout.LayoutValues,
  ) {
    self.sections = sections
    self.supplementaryItems = supplementaryItems
    self.layoutValues = layoutValues
  }
}

extension List {

  public func targetContentOffsetForProposedContentOffset(
    handler: @escaping (
      _ collectionView: UICollectionView,
      _ proposedContentOffset: CGPoint
    ) -> CGPoint
  ) -> Self {
    var copy = self
    copy.values.targetContentOffsetForProposedContentOffset = handler
    return copy
  }
}
