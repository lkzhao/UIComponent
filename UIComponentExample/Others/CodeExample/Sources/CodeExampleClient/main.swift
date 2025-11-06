import CodeExample
import UIComponent

let component = #CodeExample(Text("Hello, World!").textColor(.red))
print(component)

@GenerateCode
class Test {}

print(Test.codeRepresentation)
