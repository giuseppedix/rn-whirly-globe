require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "RNWhirlyGlobe"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = <<-DESC
                  RNWhirlyGlobe
                   DESC
  s.homepage     = "https://github.com/itrabbit/rn-whirly-globe"
  s.license      = "MIT"
  # s.license    = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author       = { "author" => "garin1221@yandex.ru" }
  s.platform     = :ios, "10.3"
  s.source       = { :git => "https://github.com/itrabbit/rn-whirly-globe.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m}"
  s.requires_arc = true

  s.dependency "React"
  s.dependency "WhirlyGlobe"
  s.dependency "WhirlyGlobeResources"
end

  