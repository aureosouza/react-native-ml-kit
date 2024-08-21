require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "RNMLKitFaceDetection"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = "https://github.com/a7med-mahmoud/react-native-ml-kit"
  s.license      = "MIT"
  s.authors      = { "Ahmed" => "a7med.mahmoud2004@gmail.com" }
  s.platforms    = { :ios => "9.0" }
  s.source       = { :git => "https://github.com/a7med-mahmoud/react-native-ml-kit.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m}"
  s.requires_arc = true

  s.dependency "React"
end
