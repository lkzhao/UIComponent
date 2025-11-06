import UIComponent
import UIKit

@freestanding(expression)
public macro CodeExample(_ value: any Component) -> any Component = #externalMacro(module: "CodeExampleMacros", type: "CodeExampleMacro")

@freestanding(expression)
public macro CodeExampleNoInsets(_ value: any Component) -> any Component = #externalMacro(module: "CodeExampleMacros", type: "CodeExampleNoInsetsMacro")

@attached(member, names: named(codeRepresentation))
public macro GenerateCode() = #externalMacro(module: "CodeExampleMacros", type: "GenerateCodeMacro")
