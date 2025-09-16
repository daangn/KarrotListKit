//
//  AccessLevelModifier.swift
//  KarrotListKit
//
//  Created by Daangn Jaxtyn on 7/18/25.
//

import Foundation

import SwiftSyntax

enum AccessLevelModifier: String, Comparable, CaseIterable, Sendable {
  case `private`
  case `fileprivate`
  case `internal`
  case `package`
  case `public`
  case `open`

  var keyword: Keyword {
    switch self {
    case .private:
      .private
    case .fileprivate:
      .fileprivate
    case .internal:
      .internal
    case .package:
      .package
    case .public:
      .public
    case .open:
      .open
    }
  }

  static func < (lhs: AccessLevelModifier, rhs: AccessLevelModifier) -> Bool {
    guard
      let lhs = Self.allCases.firstIndex(of: lhs),
      let rhs = Self.allCases.firstIndex(of: rhs)
    else {
      return false
    }
    return lhs < rhs
  }

  static func stringValue(from declaration: some DeclGroupSyntax) -> String {
    let accessLevel =
      if let protocolDecl = declaration.as(ProtocolDeclSyntax.self) {
        protocolDecl.accessLevel
      } else if let classDecl = declaration.as(ClassDeclSyntax.self) {
        classDecl.accessLevel
      } else if let structDecl = declaration.as(StructDeclSyntax.self) {
        structDecl.accessLevel
      } else if let enumDecl = declaration.as(EnumDeclSyntax.self) {
        enumDecl.accessLevel
      } else {
        AccessLevelModifier.internal
      }

    guard accessLevel != .internal else { return "" }

    // Change to public if access level is open
    if accessLevel == .open {
      return "\(AccessLevelModifier.public.rawValue) "
    }

    return "\(accessLevel.rawValue) "
  }
}

public protocol AccessLevelSyntax {
  var parent: Syntax? { get }
  var modifiers: DeclModifierListSyntax { get set }
}

extension AccessLevelSyntax {
  var accessLevelModifiers: [AccessLevelModifier]? {
    get {
      let accessLevels = modifiers.lazy.compactMap { AccessLevelModifier(rawValue: $0.name.text) }
      return accessLevels.isEmpty ? nil : Array(accessLevels)
    }
    set {
      guard let newModifiers = newValue else {
        modifiers = []
        return
      }
      let newModifierKeywords = newModifiers.map { DeclModifierSyntax(name: .keyword($0.keyword)) }
      let filteredModifiers = modifiers.filter {
        AccessLevelModifier(rawValue: $0.name.text) == nil
      }
      modifiers = filteredModifiers + newModifierKeywords
    }
  }
}

protocol DeclGroupAccessLevelSyntax: AccessLevelSyntax {}

extension DeclGroupAccessLevelSyntax {
  public var accessLevel: AccessLevelModifier {
    accessLevelModifiers?.first ?? .internal
  }
}

extension ProtocolDeclSyntax: DeclGroupAccessLevelSyntax {}
extension ClassDeclSyntax: DeclGroupAccessLevelSyntax {}
extension StructDeclSyntax: DeclGroupAccessLevelSyntax {}
extension EnumDeclSyntax: DeclGroupAccessLevelSyntax {}
extension VariableDeclSyntax: DeclGroupAccessLevelSyntax {}
