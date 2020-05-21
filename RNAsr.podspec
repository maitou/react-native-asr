require 'json'
package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name         = "RNAsr"
  s.version      = package['version']
  s.summary      = package['description']
  s.homepage     = package['homepage']
  s.license      = package['license']
  s.author       = package['author']

  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/maitou/react-native-asr.git", :tag => "v#{s.version}" }
  s.source_files  = "ios/*.{h,m}"
  s.requires_arc = true
  # usc
#  s.ios.frameworks = 'CoreLocation', 'CoreTelephony', 'AudioToolbox', 'AVFoundation', 'SystemConfiguration'
  # ifly
  s.ios.library = 'z', 'c++'
  s.ios.frameworks = 'AVFoundation',
                     'SystemConfiguration',
                     'Foundation',
                     'CoreTelephony',
                     'AudioToolbox',
                     'UIKit',
                     'CoreLocation',
                     'Contacts',
                     'AddressBook',
                     'QuartzCore',
                     'CoreGraphics'
  s.dependency "React"
  
  s.subspec 'core' do |c|
    c.source_files = 'ios/core/*.{h,m}'
  end
  
#  s.subspec 'asrusc' do |usc|
#    usc.source_files = 'ios/asrusc/lib/*.{h}',
#                       'ios/asrusc/*.{h,m}'
#    usc.ios.vendored_libraries = "ios/unisound-lib/libusc.a"
#  end

  s.subspec 'asrios' do |ss|
    ss.source_files = 'ios/asrios/*.{h,m}'
  end
  
  s.subspec 'asrifly' do |f|
    f.source_files = 'ios/asrifly/*.{h,m}'
    f.ios.vendored_frameworks = "ios/asrifly/lib/iflyMSC.framework"
  end

end
