platform :ios, '14.1'

project 'SchoolFirst', {
  'Debug' => :debug,
  'Debug Dev' => :debug,
  'Release' => :release,
  'Release Dev' => :release
}

target 'SchoolFirst' do
  use_frameworks!

  pod 'QPassLib', :path => './QPassLib'

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'NO'
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.1'
      end
    end
  end
end