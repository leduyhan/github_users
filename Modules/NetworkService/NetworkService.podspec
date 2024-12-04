#
# Be sure to run `pod lib lint NetworkService.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NetworkService'
  s.version          = '0.1.0'
  s.summary          = 'NetworkService using Moya and RxSwift for network layer'
  s.description      = 'TODO: Add long description of the pod here.'
  s.homepage         = 'https://github.com/han.sts/NetworkService'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'han.sts' => 'leduyhan.qn1994@gmail.com' }
  s.source           = { :git => 'https://github.com/han.sts/NetworkService.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = '13.0'
  s.source_files = 'Sources/NetworkService/**/*'
  
  s.resource_bundles = {
    'NetworkService' => ['Sources/NetworkService/Resources/**/**/*.{xcassets,strings}']
  }
  
  s.dependency 'Moya/RxSwift', '~> 15.0'
  s.dependency 'RxAlamofire'
  
  s.test_spec 'NetworkServiceTests' do |test_spec|
    test_spec.source_files = 'Tests/NetworkServiceTests/**/*.{h,m,swift}'
    test_spec.frameworks = 'XCTest'
    test_spec.dependency 'SnapshotTesting'
    
    test_spec.resource_bundles = {
      'NetworkServiceTests' => ['Sources/NetworkService/Resources/**/*.{json,webp,png,jpg}']
    }
  end
end
