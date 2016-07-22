platform :ios, '7.1'

target "SkyEye" do
	pod 'CocoaAsyncSocket', '~> 7.4.3'
	pod 'JHChainableAnimations', '~> 1.3.0'
	pod 'iOS-QR-Code-Encoder', '~> 0.0.1'
	pod 'ObjectiveLibModbus', '~> 0.0'
    pod 'KSCrash', '~> 1.6'
    pod 'CocoaLumberjack'
end

post_install do |installer_representation|
    installer_representation.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ARCHS'] = 'armv7 armv7s arm64'
            config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
        end
    end
end
