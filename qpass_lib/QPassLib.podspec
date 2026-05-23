Pod::Spec.new do |spec|
    spec.name                     = 'qpass_lib'
    spec.module_name              = 'QPassLib'
    spec.version                  = '1.0.0'
    spec.homepage                 = 'https://github.com/tchrnote/qpass-lib'
    spec.source                   = { :path => '.' }
    spec.authors                  = ''
    spec.license                  = ''
    spec.summary                  = 'QPass Binary Library for Kotlin Multiplatform'
    spec.vendored_frameworks      = 'QPassLib.xcframework'
    spec.libraries                = 'c++'
    spec.ios.deployment_target    = '14.1'

    spec.user_target_xcconfig = { 'ENABLE_USER_SCRIPT_SANDBOXING' => 'NO' }
end
