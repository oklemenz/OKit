Pod::Spec.new do |spec|
  spec.name          = "OKit"
  spec.version       = "1.0.0"
  spec.summary       = "Easy to use application framework for Swift, to create apps based on models and storyboards with (almost) no code."
  spec.description   = "OKit is a Swift framework to build model based apps, based on inspectable properties used to bind storyboard controllers/controls to codable Swift models"
  spec.homepage      = "https://github.com/oklemenz/OKit"
  spec.license       = { :type => "MIT" }
  spec.author        = { "Oliver Klemenz" => "oklemenz@gmail.com" }
  spec.platform      = :ios, "12.0"
  spec.source        = { :git => "https://github.com/oklemenz/OKit.git", :tag => "#{spec.version}" }
  spec.source_files  = "OKit"
  spec.swift_version = "5"
end
