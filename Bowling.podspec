#
# Be sure to run `pod lib lint Bowling.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Bowling'
  s.version          = '0.1.0'
  s.summary          = 'A short description of Bowling.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/softwarefaith@126.com/Bowling'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'softwarefaith@126.com' => 'jie.cai@mljr.com' }
  s.source           = { :git => 'https://github.com/softwarefaith@126.com/Bowling.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'Bowling/Classes/**/*'
  
  # s.resource_bundles = {
  #   'Bowling' => ['Bowling/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'Alamofire','~> 4.9'
  #s.dependency 'Alamofire','~> 5.0.0-rc.2'
  s.dependency 'HandyJSON','~> 5.0.0'
end
