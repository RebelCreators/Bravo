Pod::Spec.new do |s|
  s.name               = 'Bravo'
  s.version            =  '0.0.0'
  s.license            =  { :type => 'Apache 2.0' }
  s.summary            =  'An iOS SDK to connect to Alpha servers'
  s.homepage           =  'https://www.rebelcreators.com'
  s.author             =  { 'Lorenzo Stanton' => 'lstanii@nmsu.edu' }
  s.source             =  { :git => 'git@github.com:RebelCreators/BravoSpecs.git', :branch => "master" }

  s.platform = :ios
  s.ios.deployment_target = '9.0'
  s.requires_arc = true

  s.source_files = 'src/*.{swift,h,m}'
  s.public_header_files = 'src/*.h'
  
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '3.0' }
  s.dependency 'Alamofire', '~> 4.0'
  s.dependency 'EVReflection', '~> 3.1.2'
  s.dependency 'SwiftKeychainWrapper', '~> 3.0'
end
