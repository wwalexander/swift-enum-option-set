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
        let enumName = node
            .arguments?
            .as(LabeledExprListSyntax.self)?
            .lazy
            .first { $0.label?.text == "enumName" }?
            .expression
            .as(StringLiteralExprSyntax.self)?
            .segments
            .first?
            .as(StringSegmentSyntax.self)?
            .content ?? "Option"

        let structDeclaration = declaration.as(StructDeclSyntax.self)

        guard let structDeclaration else {
            context.diagnose(.init(
                node: declaration,
                message: OptionSetMacroDiagnostic.requiresStruct))

            return []
        }

        let enumDeclaration = structDeclaration
            .memberBlock
            .members.lazy
            .map(\.decl)
            .compactMap { $0.as(EnumDeclSyntax.self) }
            .first { $0.name.text == enumName.text }

        guard let enumDeclaration else {
            context.diagnose(.init(
                node: structDeclaration,
                message: OptionSetMacroDiagnostic.requiresOptionsEnum(name: enumName.text)))

            return []
        }

        let rawType = enumDeclaration
            .inheritanceClause?
            .inheritedTypes.lazy
            .map(\.type)
            .first

        let modifier = declaration.modifiers.lazy
            .map(\.name)
            .first { $0.tokenKind == .keyword(.public) } ?? .keyword(.internal)

        return [
            "\(modifier) typealias RawValue = \(rawType)",
            "\(modifier) var rawValue: RawValue",
            "\(modifier) init(rawValue: RawValue) { self.rawValue = rawValue }"
        ] + enumDeclaration.memberBlock.members.lazy
            .map(\.decl)
            .compactMap { $0.as(EnumCaseDeclSyntax.self) }
            .compactMap(\.elements)
            .flatMap(\.self)
            .map(\.name)
            .map { name in "\(modifier) static let \(name): Self = Self(rawValue: 1 << \(enumName).\(name).rawValue)" }
    }

    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
        providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
        conformingTo protocols: [SwiftSyntax.TypeSyntax],
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        [
            try .init("extension \(type): OptionSet {}"),
        ]
    }
}

enum OptionSetMacroDiagnostic: DiagnosticMessage {
    case unexpectedArgument(name: String)
    case requiresStruct
    case requiresOptionsEnum(name: String)
    case requiresOptionsEnumRawType

    var message: String {
        switch self {
        case let .unexpectedArgument(name): "Unexpected argument \(name)"
        case .requiresStruct: "OptionSet macro can only be applied to a struct"
        case let .requiresOptionsEnum(name): "OptionSet macro requires nested enum \(name)"
        case .requiresOptionsEnumRawType: "OptionSet macro requires a raw type"
        }
    }

    var severity: DiagnosticSeverity {
        .error
    }

    var diagnosticID: MessageID {
        .init(domain: "Swift", id: "OptionSet.\(self)")
    }
}

@main
struct OptionSetMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        OptionSetMacro.self,
    ]
}
