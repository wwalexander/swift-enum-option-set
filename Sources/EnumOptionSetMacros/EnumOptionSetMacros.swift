import SwiftDiagnostics
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct OptionSetMacro: MemberMacro, ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let structDecl = declaration.as(StructDeclSyntax.self)!

        let enumDecl = structDecl
            .memberBlock
            .members
            .lazy
            .compactMap { member in member.decl.as(EnumDeclSyntax.self) }
            .first { enumDecl in enumDecl.name.text == "Option" }!

        let rawType = enumDecl.inheritanceClause?.inheritedTypes.lazy.map(\.type).first!

        return ["let rawValue: \(rawType)"] + enumDecl
            .memberBlock
            .members
            .lazy
            .compactMap { member in member.decl.as(EnumCaseDeclSyntax.self) }
            .flatMap(\.elements)
            .map(\.name)
            .map { name in "static let \(name): Self = Self(rawValue: 1 << Option.\(name).rawValue)" }
    }

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        [
            .init(
                extendedType: type,
                inheritanceClause: .init(inheritedTypes: [
                    .init(type: "EnumOptionSet" as TypeSyntax)
                ]),
                memberBlock: "{}"
            )
        ]
    }
}

@main
struct OptionSetMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        OptionSetMacro.self,
    ]
}
