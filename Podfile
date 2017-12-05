platform :ios, '9.1'
use_frameworks!

target 'QuickChat' do

	pod 'Firebase/Database'
	pod 'Firebase/Auth'
	pod 'Firebase/Storage'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.name == 'Debug'
        config.build_settings['OTHER_SWIFT_FLAGS'] = ['$(inherited)', '-Onone']
        config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Owholemodule'
      end
    end
  end
end