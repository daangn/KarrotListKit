//
//  Created by Daangn Jaxtyn on 7/18/25.
//  Copyright © 2025 Danggeun Market Inc. All rights reserved.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct AddComponentModifierMacro: PeerMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingPeersOf declaration: some DeclSyntaxProtocol,
    in context: some MacroExpansionContext
  ) throws -> [DeclSyntax] {
    #if canImport(SwiftSyntax600)
    guard
      let structDecl = context.lexicalContext.compactMap({ $0.as(StructDeclSyntax.self) }).first
    else {
      throw KarrotListKitMacroError(message: "@AddComponentModifier can only be used on properties inside structs")
    }

    guard
      let varDecl = declaration.as(VariableDeclSyntax.self),
      varDecl.bindingSpecifier.tokenKind == .keyword(.var)
    else {
      throw KarrotListKitMacroError(
        message: "@AddComponentModifier can only be applied to variable property"
      )
    }

    guard
      let binding = varDecl.bindings.first,
      let identifier = binding.pattern.as(IdentifierPatternSyntax.self),
      let typeAnnotation = binding.typeAnnotation,
      let optionalType = typeAnnotation.type.as(OptionalTypeSyntax.self),
      let functionType = convertToFunctionType(from: optionalType)
    else {
      throw KarrotListKitMacroError(
        message: "@AddComponentModifier can only be applied to optional closure properties"
      )
    }

    let propertyName = identifier.identifier.text
    let accessLevelString = extractAccessLevel(from: structDecl)
    let methodName = propertyName.replacingOccurrences(of: "Handler", with: "")
    let handlerType = functionType.description.trimmingCharacters(in: .whitespaces)

    let componentModifier = """
      \(accessLevelString)func \(methodName)(_ handler: @escaping \(handlerType)) -> Self {
        var copy = self
        copy.\(propertyName) = handler
        return copy
      }
      """

    return [
      DeclSyntax(stringLiteral: componentModifier),
    ]
    #else
    throw KarrotListKitMacroError(
      message: "@AddComponentModifier macro requires SwiftSyntax 600.0.0 or later."
    )
    #endif
  }

  private static func convertToFunctionType(
    from optionalType: OptionalTypeSyntax
  ) -> FunctionTypeSyntax? {
    guard
      let tupleType = optionalType.wrappedType.as(TupleTypeSyntax.self),
      tupleType.elements.count == 1,
      let firstElement = tupleType.elements.first
    else {
      return optionalType.wrappedType.as(FunctionTypeSyntax.self)
    }

    return firstElement.type.as(FunctionTypeSyntax.self)
  }

  private static func extractAccessLevel(from structDecl: StructDeclSyntax) -> String {
    let structAccessLevel = structDecl.modifiers.first(where: { modifier in
      modifier.name.tokenKind == .keyword(.public) ||
        modifier.name.tokenKind == .keyword(.internal) ||
        modifier.name.tokenKind == .keyword(.fileprivate) ||
        modifier.name.tokenKind == .keyword(.private)
    })

    guard let structAccessLevel else { return "" }
    return structAccessLevel.name.text + " "
  }
}
