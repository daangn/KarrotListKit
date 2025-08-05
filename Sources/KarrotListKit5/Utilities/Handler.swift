//
//  Handler.swift
//  KarrotListKit
//
//  Created by Max.kim on 8/5/25.
//

@propertyWrapper struct Handler<Value> {

  // Swift

  init<Root>(
    wrappedValue: Value,
    _ selector: (Root) -> Value
  ) {
    self.wrappedValue = wrappedValue
  }

  init<Root, V>(
    _ selector: (Root) -> V
  ) where Value == V? {
    self.wrappedValue = nil
  }

  // @objc optional

  init<Root>(
    wrappedValue: Value,
    _ selector: (Root) -> Value?
  ) {
    self.wrappedValue = wrappedValue
  }

  init<Root, V>(
    _ selector: (Root) -> V?
  ) where Value == V? {
    self.wrappedValue = nil
  }

  var wrappedValue: Value
}

@propertyWrapper struct Handlers<Value> {

  // Swift

  init<Root>(
    wrappedValue: [Value] = [],
    _ selector: (Root) -> Value
  ) {
    self.wrappedValue = wrappedValue
  }

  // @objc optional

  init<Root>(
    wrappedValue: [Value] = [],
    _ selector: (Root) -> Value?
  ) {
    self.wrappedValue = wrappedValue
  }

  var wrappedValue: [Value]
}
