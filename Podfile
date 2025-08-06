platform :ios, '15.0'

target 'XCFrameworkPackager' do
  use_frameworks!

#  pod 'SnapKit', :podspec => './SnapKit/SnapKit.podspec'
#  pod 'ZLPhotoBrowser', :path => './ZLPhotoBrowser'
#  pod 'LookinServer', :podspec => './LookinServer/LookinServer.podspec'
#  pod 'YYCache', :path => './YYCache'

  pod 'YYCache', :path => './LocalPods/YYCache'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end
