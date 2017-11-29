Pod::Spec.new do |s|
  s.name               = 'HHSDK'
  s.version            =  '1.0.0'
  s.license            =  { :type => 'Apache 2.0' }
  s.summary            =  'An iOS SDK to connect to Alpha servers'
  s.homepage           =  'https://www.rebelcreators.com'
  s.author             =  { 'Lorenzo Stanton' => 'lstanii@nmsu.edu' }
  s.source             =  { :git => 'git@github.com:RebelCreators/Bravo.git', :branch => "master" }
  s.platform = :ios
  s.ios.deployment_target = '10.0'
  s.requires_arc = true

  s.source_files = 'src/hotthelpers/**/*.{swift,h,m}'
  s.public_header_files = 'src/hotthelpers/**/*.h'
  s.frameworks = 'Foundation'

  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '3.0' }

  s.dependency 'Bravo'
end
