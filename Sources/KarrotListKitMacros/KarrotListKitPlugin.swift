//
//  KarrotListKitPlugin.swift
//  KarrotListKit
//
//  Created by Daangn Jaxtyn on 7/18/25.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct KarrotListKitKitPlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    AddComponentModifierMacro.self,
  ]
}
