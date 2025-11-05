import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct CodeExampleMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        guard let argument = node.arguments.first?.expression else {
            fatalError("compiler bug: the macro does not have any arguments")
        }

        return """
            {
                let (component, code) = (
                    \(argument), 
                    \(literal: argument.description.trimLeadingWhitespacesBasedOnFirstLine())
                )
                return CodeExampleComponent(content: component, code: code)
            }()
            """
    }
}

public struct GenerateCodeMacro: MemberMacro {
    public static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, conformingTo protocols: [TypeSyntax], in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        [
            """
            static var codeRepresentation: String {
                \(literal: declaration.with(\.attributes, []).description.trimLeadingWhitespacesBasedOnFirstLine())
            }
            """
        ]
    }
}

@main
struct CodeExamplePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        CodeExampleMacro.self,
        GenerateCodeMacro.self
    ]
}
