#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint millicast_flutter_sdk.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'millicast_flutter_sdk'
  s.version          = '1.2.0'
  s.summary          = 'A Flutter SDK that allows developers to simplify Millicast services integration into their own Android and iOS apps.'
  s.homepage         = 'https://github.com/millicast/flutter-sdk/ios'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Millicast' => 'fabian.cancela@dolby.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'WebRTC-SDK', '104.5112.17'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
