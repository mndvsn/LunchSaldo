source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

swift_version = "4.0"

target 'LunchSaldo' do
  pod 'Alamofire'
  pod 'SwiftHEXColors', git: 'https://github.com/thii/SwiftHEXColors.git'
  pod 'AEXML'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '4.0'
    end
  end
end
