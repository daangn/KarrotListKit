extension Dictionary {
  init<S: Sequence>(
    _ values: S,
    key: (Value) -> Key,
    uniquingKeysWith combine: (Value, Value) throws -> Value
  ) rethrows where S.Element == Value {
    try self.init(
      values.map { value in (key(value), value) },
      uniquingKeysWith: combine
    )
  }
}
