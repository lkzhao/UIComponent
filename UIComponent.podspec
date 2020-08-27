Pod::Spec.new do |s|
  s.name             = "UIComponent"
  s.version          = "0.9.0"
  s.summary          = "A modern swift framework for building data-driven view components that renders with UIKit."

  s.description      = <<-DESC
                        ### Features

                        * Declaritive API for building UIKit view components
                        * Automatically update UI when data changes
                        * Composable & hot swappable sections, layouts, & animations
                        * Strong type checking powered by Swift Generics
                      DESC

  s.homepage         = "https://github.com/lkzhao/UIComponent"
  s.license          = 'MIT'
  s.author           = { "Luke" => "lzhaoyilun@gmail.com" }
  s.source           = { :git => "https://github.com/lkzhao/UIComponent.git", :tag => s.version.to_s }

  s.ios.deployment_target  = '11.0'
  s.ios.frameworks         = 'UIKit', 'Foundation'

  s.requires_arc = true

  s.source_files = 'Sources/**/*.swift'
end
