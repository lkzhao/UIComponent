import UIComponent

@freestanding(expression)
public macro CodeExample(_ value: any Component) -> any Component = #externalMacro(module: "CodeExampleMacros", type: "CodeExampleMacro")

@freestanding(expression)
public macro CodeExampleNoInsets(_ value: any Component) -> any Component = #externalMacro(module: "CodeExampleMacros", type: "CodeExampleNoInsetsMacro")

@freestanding(expression)
public macro CodeExampleNoWrap(_ value: any Component) -> any Component = #externalMacro(module: "CodeExampleMacros", type: "CodeExampleNoWrapMacro")

@attached(member, names: named(codeRepresentation))
public macro GenerateCode() = #externalMacro(module: "CodeExampleMacros", type: "GenerateCodeMacro")
