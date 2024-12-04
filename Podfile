# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'TymeX' do
  use_frameworks!
  pod 'NetworkService', :path => 'Modules/NetworkService', :testspecs => ['NetworkServiceTests'], :inhibit_warnings => false
  pod 'Coordinator', :path => 'Modules/Coordinator'
  pod 'DesignSystem', :path => 'Modules/DesignSystem'
  pod 'Domain', :path => 'Modules/Domain'
  pod 'Users', :path => 'Modules/Users', :testspecs => ['UsersTests'], :inhibit_warnings => false
  pod 'AppShared', :path => 'Modules/AppShared'
  pod 'LocalStorage', :path => 'Modules/LocalStorage', :testspecs => ['LocalStorageTests'], :inhibit_warnings => false
  pod 'Data', :path => 'Modules/Data'

  target 'TymeXTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'TymeXUITests' do
    # Pods for testing
  end
end
