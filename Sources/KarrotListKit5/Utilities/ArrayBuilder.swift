@resultBuilder
public struct ArrayBuilder<T> {

  public static func buildExpression(_ expression: T) -> [T] {
    [expression]
  }

  public static func buildExpression(_ expression: T?) -> [T] {
    [expression].compactMap { $0 }
  }

  public static func buildExpression(_ expression: [T]) -> [T] {
    expression
  }

  public static func buildBlock(_ components: [T]...) -> [T] {
    components.flatMap { $0 }
  }

  public static func buildArray(_ components: [[T]]) -> [T] {
    components.flatMap { $0 }
  }
}

public typealias SectionsBuilder<Layout: CollectionLayout> = ArrayBuilder<Section<Layout>>
public typealias ItemsBuilder<Layout: CollectionLayout> = ArrayBuilder<Item<Layout>>
public typealias SupplementaryItemsBuilder<T: SupplementaryItemProtocol> = ArrayBuilder<T>
public typealias DecorationItemsBuilder<T: DecorationItemProtocol> = ArrayBuilder<T>

public typealias ElementKindGroupsBuilder<Item> = ArrayBuilder<ElementKindGroup<Item>>
