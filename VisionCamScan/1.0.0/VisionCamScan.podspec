#
# Be sure to run `pod lib lint VisionCamScan.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'VisionCamScan'
  s.version          = '1.0.0'
  s.summary          = 'A library to scan info using the device camera and on-device machine learning'

  s.homepage         = 'https://github.com/anilsanto/VisionCamScan'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'anilsanto' => 'santoanil@gmail.com' }
  s.source           = { :git => 'https://github.com/anilsanto/VisionCamScan.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '13.0'
  s.swift_versions = ['5.1', '5.2', '5.3']

  s.source_files = 'VisionCamScan/Classes/**/*'
  
  # s.resource_bundles = {
  #   'VisionCamScan' => ['VisionCamScan/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
