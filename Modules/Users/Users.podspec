#
# Be sure to run `pod lib lint Users.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Users'
  s.version          = '0.1.0'
  s.summary          = 'A short description of Users.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/han.sts/Users'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'han.sts' => 'leduyhan.qn1994@gmail.com' }
  s.source           = { :git => 'https://github.com/han.sts/Users.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '13.0'
  s.source_files = 'Sources/Users/**/*'

  s.dependency 'Domain'
  s.dependency 'AppShared'
  s.dependency 'RxRelay'
  s.dependency 'SnapKit'
  s.dependency 'Kingfisher'
  s.dependency 'RxCocoa'
  s.dependency 'Data'
  s.dependency 'Coordinator'
  
  s.test_spec 'UsersTests' do |test_spec|
    test_spec.source_files = 'Tests/UsersTests/**/*.{h,m,swift}'
    test_spec.frameworks = 'XCTest'
    test_spec.dependency 'SnapshotTesting'
    test_spec.dependency 'RxTest'
    
    test_spec.resource_bundles = {
      'UsersTests' => ['Sources/Users/Resources/**/*.{json,webp,png,jpg}']
    }
  end
end
