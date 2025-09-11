//
//  File.swift
//  KarrotListKit
//
//  Created by Daangn Jaxtyn on 7/18/25.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(KarrotListKitMacros)
import KarrotListKitMacros
#endif

final class AddComponentModifierMacroTests: XCTestCase {

#if canImport(KarrotListKitMacros)
  let testMacros: [String: Macro.Type] = [
    "AddComponentModifier": AddComponentModifierMacro.self,
    "ListKitComponent": ListKitComponentMacro.self,
  ]
#endif

  func testExpansionWithPublicStruct() throws {
#if canImport(KarrotListKitMacros)
    assertMacroExpansion(
      """
      @ListKitComponent
      public struct VerticalLayoutItemComponent {

        @AddComponentModifier
        public var onTapButtonHandler: (() -> Void)?

        @AddComponentModifier
        private var onTapButtonWithValueHandler: ((Int) -> Void)?

        @AddComponentModifier
        internal var onTapButtonWithValuesHandler: ((Int, String) -> Void)?

        @AddComponentModifier
        var onTapButtonWithNamedValuesHandler: ((_ intValue: Int, _ stringValue: String) -> Void)?
      }
      """,
      expandedSource: """
        public struct VerticalLayoutItemComponent {
          public var onTapButtonHandler: (() -> Void)?
          private var onTapButtonWithValueHandler: ((Int) -> Void)?
          internal var onTapButtonWithValuesHandler: ((Int, String) -> Void)?
          var onTapButtonWithNamedValuesHandler: ((_ intValue: Int, _ stringValue: String) -> Void)?
        
          public func onTapButton(_ handler: @escaping () -> Void) -> Self {
            var copy = self
            copy.onTapButtonHandler = handler
            return copy
          }
        
          public func onTapButtonWithValue(_ handler: @escaping (Int) -> Void) -> Self {
            var copy = self
            copy.onTapButtonWithValueHandler = handler
            return copy
          }
        
          public func onTapButtonWithValues(_ handler: @escaping (Int, String) -> Void) -> Self {
            var copy = self
            copy.onTapButtonWithValuesHandler = handler
            return copy
          }
        
          public func onTapButtonWithNamedValues(_ handler: @escaping (_ intValue: Int, _ stringValue: String) -> Void) -> Self {
            var copy = self
            copy.onTapButtonWithNamedValuesHandler = handler
            return copy
          }
        }
        
        extension VerticalLayoutItemComponent: Component {
        }
        """,
      macros: testMacros,
      indentationWidth: .spaces(2)
    )
#else
    throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
  }
  
  func testExpansionWithInternalStruct() throws {
#if canImport(KarrotListKitMacros)
    assertMacroExpansion(
      """
      @ListKitComponent
      struct InternalComponent {
        @AddComponentModifier
        var onTapHandler: (() -> Void)?
      }
      """,
      expandedSource: """
        struct InternalComponent {
          var onTapHandler: (() -> Void)?
        
          func onTap(_ handler: @escaping () -> Void) -> Self {
            var copy = self
            copy.onTapHandler = handler
            return copy
          }
        }
        
        extension InternalComponent: Component {
        }
        """,
      macros: testMacros,
      indentationWidth: .spaces(2)
    )
#else
    throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
  }
  
  func testExpansionWithPrivateStruct() throws {
#if canImport(KarrotListKitMacros)
    assertMacroExpansion(
      """
      @ListKitComponent
      private struct PrivateComponent {
        @AddComponentModifier
        var onTapHandler: (() -> Void)?
      }
      """,
      expandedSource: """
        private struct PrivateComponent {
          var onTapHandler: (() -> Void)?
        
          private func onTap(_ handler: @escaping () -> Void) -> Self {
            var copy = self
            copy.onTapHandler = handler
            return copy
          }
        }
        
        extension PrivateComponent: Component {
        }
        """,
      macros: testMacros,
      indentationWidth: .spaces(2)
    )
#else
    throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
  }
}
