Pod::Spec.new do |s|
  s.name             = "UIComponent"
  s.version          = "0.7.0"
  s.summary          = "Write UI in crazy speed, with great perf & no limitations."

  s.description      = <<-DESC
                        This framework allows you to build UI using UIKit with syntax similar to SwiftUI. You can think about this as an improved `UICollectionView`.
                        
                        ### Highlights:
                        * Great performance through global cell reuse.
                        * Built in layouts including `Stack`, `Flow`, & `Waterfall`.
                        * Declaritive API based on `resultBuilder` and modifier syntax.
                        * Work seemless with existing UIKit views, viewControllers, and transitions.
                        * `dynamicMemberLookup` support for all ViewComponents which can help you easily update your UIKit views.
                        * `Animator` API to apply animations when cells are being moved, updated, inserted, or deleted.
                        * Simple architecture for anyone to be able to understand.
                        * Easy to create your own Components.
                        * No state management or two-way binding.
                       DESC

  s.homepage         = "https://github.com/lkzhao/UIComponent"
  s.license          = 'MIT'
  s.author           = { "Luke" => "lzhaoyilun@gmail.com" }
  s.source           = { :git => "https://github.com/lkzhao/UIComponent.git", :tag => s.version.to_s }

  s.ios.deployment_target  = '13.0'
  s.ios.frameworks         = 'UIKit', 'Foundation'

  s.requires_arc = true

  s.source_files = 'Sources/**/*.swift'
end