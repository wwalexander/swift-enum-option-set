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
            .first { enumDecl in enumDecl.name.text == "Option" }

        guard let enumDecl else {
            context.diagnose(.init(node: structDecl, message: OptionSetMacroDiagnostic.requiresOptionEnum))
            return []
        }

        guard let rawType = enumDecl.inheritanceClause?.inheritedTypes.lazy.map(\.type).first else {
            context.diagnose(.init(node: enumDecl, message: OptionSetMacroDiagnostic.requiresOptionEnumRawType))
            return []
        }
        
        let rawValueDecl = "let rawValue: \(rawType)" as DeclSyntax

        return [rawValueDecl] + enumDecl
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

enum OptionSetMacroDiagnostic: DiagnosticMessage {
    case requiresStruct
    case requiresOptionEnum
    case requiresOptionEnumRawType

    var message: String {
        switch self {
        case .requiresStruct: "OptionSet macro can only be applied to a struct"
        case .requiresOptionEnum: "OptionSet macro requires nested enum Option"
        case .requiresOptionEnumRawType: "OptionSet macro requires a raw type"
        }
    }

    var severity: DiagnosticSeverity { .error }
    var diagnosticID: MessageID { .init(domain: "Swift", id: "OptionSet.\(self)")  }
}

@main
struct OptionSetMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        OptionSetMacro.self,
    ]
}
