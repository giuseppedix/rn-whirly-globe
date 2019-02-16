require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = 'RNWhirlyGlobe'
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = <<-DESC
                  RNWhirlyGlobe
                   DESC
  s.homepage     = 'https://github.com/itrabbit/rn-whirly-globe'
  s.license      = 'MIT'
  s.author       = { 'author' => "garin1221@yandex.ru" }
  s.platform     = :ios, '10.3'
  s.source       = { :git => 'https://github.com/itrabbit/rn-whirly-globe.git', :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m}"
  s.requires_arc = true

  s.dependency 'React'

  s.default_subspec = 'MaplyComponent'

  s.compiler_flags = '-D__USE_SDL_GLES__ -D__IPHONEOS__ -DSQLITE_OPEN_READONLY -DHAVE_PTHREAD=1 -DUNORDERED=1 -DLASZIPDLL_EXPORTS=1'
  s.xcconfig = { "HEADER_SEARCH_PATHS" => " \"$(PODS_ROOT)/eigen/\" \"$(PODS_ROOT)/KissXML/KissXML/\" \"${PODS_ROOT}/Headers/Private/RNWhirlyGlobe/protobuf/src/\" \"${PODS_ROOT}/Headers/Private/RNWhirlyGlobe/laszip/include/\" \"${PODS_ROOT}/Headers/Private/RNWhirlyGlobe/clipper\" \"$(SDKROOT)/usr/include/libxml2\" \"${PODS_ROOT}/Headers/Private/RNWhirlyGlobe/glues/include/\" \"${PODS_ROOT}/Headers/Private/RNWhirlyGlobe/WhirlyGlobe-MaplyComponent/include/private/\" \"${PODS_ROOT}/Headers/Private/RNWhirlyGlobe/WhirlyGlobe-MaplyComponent/include/vector_tiles/\" " }

  s.subspec 'locallibs' do |ll|
    ll.source_files = 'libs/WhirlyGlobeMaply/common/local_libs/aaplus/**/*.{h,cpp}',
        'libs/WhirlyGlobeMaply/common/local_libs/clipper/cpp/*.{cpp,hpp}',
        'libs/WhirlyGlobeMaply/common/local_libs/laszip/include/laszip/*.h',
        'libs/WhirlyGlobeMaply/common/local_libs/laszip/src/*.{cpp,hpp}',
        'libs/WhirlyGlobeMaply/common/local_libs/protobuf/src/google/protobuf/*.{cc,h}',
        'libs/WhirlyGlobeMaply/common/local_libs/protobuf/src/google/protobuf/stubs/*.{cc,h}',
        'libs/WhirlyGlobeMaply/common/local_libs/protobuf/src/google/protobuf/io/*.{cc,h}',
        'libs/WhirlyGlobeMaply/common/local_libs/protobuf/src/google/protobuf/testing/*.h',
        'libs/WhirlyGlobeMaply/common/local_libs/shapefile/**/*.{c,h}'
    ll.preserve_paths = 'libs/WhirlyGlobeMaply/common/local_libs/protobuf/src/google/protobuf/*.h',
        'libs/WhirlyGlobeMaply/common/local_libs/protobuf/src/google/protobuf/stubs/*.h',
        'libs/WhirlyGlobeMaply/common/local_libs/protobuf/src/google/protobuf/io/*.h',
        'libs/WhirlyGlobeMaply/common/local_libs/laszip/include/laszip/*.h',
        'libs/WhirlyGlobeMaply/common/local_libs/laszip/src/*.hpp'
    ll.private_header_files = 'libs/WhirlyGlobeMaply/common/local_libs/aaplus/**/*.h',
        'libs/WhirlyGlobeMaply/common/local_libs/clipper/**/*.hpp',
        'libs/WhirlyGlobeMaply/common/local_libs/laszip/**/**/*.h',
        'libs/WhirlyGlobeMaply/common/local_libs/laszip/**/*.hpp',
        'libs/WhirlyGlobeMaply/common/local_libs/protobuf/**/**/**/*.h',
        'libs/WhirlyGlobeMaply/common/local_libs/protobuf/**/**/**/**/*.h',
        'libs/WhirlyGlobeMaply/common/local_libs/shapefile/**/*.h'
    ll.header_mappings_dir = 'libs/WhirlyGlobeMaply/common/local_libs'
  end

  s.subspec 'glues' do |gl|
    gl.source_files = 'libs/WhirlyGlobeMaply/common/local_libs/glues/**/*.{c,h}'
    gl.preserve_paths = 'libs/WhirlyGlobeMaply/common/local_libs/glues/**/*.i'
    gl.private_header_files = 'libs/WhirlyGlobeMaply/common/local_libs/glues/**/*.h'
    gl.header_mappings_dir = 'libs/WhirlyGlobeMaply/common/local_libs'
  end

  s.subspec 'MaplyComponent' do |mc|
    mc.source_files = 'libs/WhirlyGlobeMaply/ios/library/WhirlyGlobeLib/src/*.{mm,m}',
        'libs/WhirlyGlobeMaply/ios/library/WhirlyGlobeLib/include/*.h',
        'libs/WhirlyGlobeMaply/ios/library/WhirlyGlobe-MaplyComponent/include/**/*.h',
        'libs/WhirlyGlobeMaply/ios/library/WhirlyGlobe-MaplyComponent/src/**/*.{mm,m,cpp}'
    mc.public_header_files = 'libs/WhirlyGlobeMaply/ios/library/WhirlyGlobe-MaplyComponent/include/*.h',
        'libs/WhirlyGlobeMaply/ios/library/WhirlyGlobe-MaplyComponent/include/vector_tiles/*.h'
    mc.private_header_files = 'libs/WhirlyGlobeMaply/ios/library/WhirlyGlobeLib/include/*.h',
        'libs/WhirlyGlobeMaply/ios/**/vector_tile.pb.h', 'libs/WhirlyGlobeMaply/ios/**/MaplyBridge.h'
    mc.header_mappings_dir = 'libs/WhirlyGlobeMaply/ios/library'
    mc.dependency 'RNWhirlyGlobe/locallibs'
    mc.dependency 'RNWhirlyGlobe/glues'
    mc.dependency 'SMCalloutView'
    mc.dependency 'FMDB'
    mc.dependency 'libjson'
    mc.dependency 'KissXML'
    mc.dependency 'eigen'
    mc.dependency 'proj4'
    mc.libraries = 'z', 'xml2', 'c++', 'sqlite3'
    mc.frameworks = 'CoreLocation', 'MobileCoreServices', 'SystemConfiguration', 'CFNetwork', 'UIKit', 'OpenGLES'
  end
end