
Pod::Spec.new do |s|

  s.name         = "YLPhotoBrowser"
  s.version      = "1.0.0"
  s.summary      = "A lightweight picture browsing framework"
  s.homepage     = "https://github.com/Hearsayer/YLPhotoBrowser"
  s.license      = "MIT"
  s.author       = { "Hearsayer" => "hearsayer@foxmail.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/Hearsayer/YLPhotoBrowser.git", :tag => "#{s.version}" }
  s.source_files  = "PhotoBrowser/*.{swift}"
  s.requires_arc = true
  s.dependency "Kingfisher"

end
