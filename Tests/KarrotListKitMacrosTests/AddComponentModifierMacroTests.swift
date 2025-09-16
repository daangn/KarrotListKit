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
  ]
  #endif

  func testExpansionWithPublicStruct() throws {
    #if canImport(KarrotListKitMacros)
    assertMacroExpansion(
      """
      public struct VerticalLayoutItemComponent: Component {

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
        public struct VerticalLayoutItemComponent: Component {
          public var onTapButtonHandler: (() -> Void)?

          public func onTapButton(_ handler: @escaping () -> Void) -> Self {
            var copy = self
            copy.onTapButtonHandler = handler
            return copy
          }
          private var onTapButtonWithValueHandler: ((Int) -> Void)?

          public func onTapButtonWithValue(_ handler: @escaping (Int) -> Void) -> Self {
            var copy = self
            copy.onTapButtonWithValueHandler = handler
            return copy
          }
          internal var onTapButtonWithValuesHandler: ((Int, String) -> Void)?

          public func onTapButtonWithValues(_ handler: @escaping (Int, String) -> Void) -> Self {
            var copy = self
            copy.onTapButtonWithValuesHandler = handler
            return copy
          }
          var onTapButtonWithNamedValuesHandler: ((_ intValue: Int, _ stringValue: String) -> Void)?

          public func onTapButtonWithNamedValues(_ handler: @escaping (_ intValue: Int, _ stringValue: String) -> Void) -> Self {
            var copy = self
            copy.onTapButtonWithNamedValuesHandler = handler
            return copy
          }
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
      struct InternalComponent: Component {
        @AddComponentModifier
        var onTapHandler: (() -> Void)?
      }
      """,
      expandedSource: """
        struct InternalComponent: Component {
          var onTapHandler: (() -> Void)?

          func onTap(_ handler: @escaping () -> Void) -> Self {
            var copy = self
            copy.onTapHandler = handler
            return copy
          }
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
      private struct PrivateComponent: Component {
        @AddComponentModifier
        var onTapHandler: (() -> Void)?
      }
      """,
      expandedSource: """
        private struct PrivateComponent: Component {
          var onTapHandler: (() -> Void)?

          private func onTap(_ handler: @escaping () -> Void) -> Self {
            var copy = self
            copy.onTapHandler = handler
            return copy
          }
        }
        """,
      macros: testMacros,
      indentationWidth: .spaces(2)
    )
    #else
    throw XCTSkip("macros are only supported when running tests for the host platform")
    #endif
  }

  func testNonStructError() throws {
    #if canImport(KarrotListKitMacros)
    assertMacroExpansion(
      """
      enum PrivateComponent: Component {
        @AddComponentModifier
        var onTapHandler: (() -> Void)?
      }
      """,
      expandedSource: """
        enum PrivateComponent: Component {
          var onTapHandler: (() -> Void)?
        }
        """,
      diagnostics: [
        DiagnosticSpec(
          message: "KarrotListKitMacroError(message: \"@AddComponentModifier can only be used on properties inside structs\")",
          line: 2,
          column: 3
        ),
      ],
      macros: testMacros,
      indentationWidth: .spaces(2)
    )
    #else
    throw XCTSkip("macros are only supported when running tests for the host platform")
    #endif
  }

  func testPropertyError() throws {
    #if canImport(KarrotListKitMacros)
    assertMacroExpansion(
      """
      struct PrivateComponent: Component {
        @AddComponentModifier
        func onTapHandler() {}
      
        @AddComponentModifier
        let onTap2Handler: (() -> Void)? = nil
      
        @AddComponentModifier
        var onTap3Handler: Int = 0
      
        @AddComponentModifier
        var onTap4: (() -> Void)?
      }
      """,
      expandedSource: """
        struct PrivateComponent: Component {
          func onTapHandler() {}
          let onTap2Handler: (() -> Void)? = nil
          var onTap3Handler: Int = 0
          var onTap4: (() -> Void)?
        }
        """,
      diagnostics: [
        DiagnosticSpec(
          message: "KarrotListKitMacroError(message: \"@AddComponentModifier can only be applied to variable property\")",
          line: 2,
          column: 3
        ),
        DiagnosticSpec(
          message: "KarrotListKitMacroError(message: \"@AddComponentModifier can only be applied to variable property\")",
          line: 5,
          column: 3
        ),
        DiagnosticSpec(
          message: "KarrotListKitMacroError(message: \"@AddComponentModifier can only be applied to optional closure properties\")",
          line: 8,
          column: 3
        ),
        DiagnosticSpec(
          message: "KarrotListKitMacroError(message: \"@AddComponentModifier can only be applied to properties with \\'Handler\\' suffix\")",
          line: 11,
          column: 3
        ),
      ],
      macros: testMacros,
      indentationWidth: .spaces(2)
    )
    #else
    throw XCTSkip("macros are only supported when running tests for the host platform")
    #endif
  }

}
