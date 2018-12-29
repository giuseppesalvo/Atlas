Pod::Spec.new do |s|
  s.name             = 'AtlasSwift'
  s.version          = '0.0.13'
  s.summary          = 'Atlas is a redux-like store for your swift apps without the reducer layer'

  s.description      = <<-DESC
                        Atlas is a redux-like store for your swift iOS/macOS/tvOS apps without the reducer layer
                        DESC
  s.homepage         = 'https://github.com/giuseppesalvo/atlas'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Giuseppe' => 'giuseppesalvo@outlook.it' }
  s.source           = { :git => 'https://github.com/giuseppesalvo/Atlas.git', :tag => s.version.to_s }
  s.social_media_url = 'https://github.com/giuseppesalvo'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
  s.watchos.deployment_target = '2.0'
  s.tvos.deployment_target = '9.0'
  s.source_files = 'AtlasSwift/Classes/**/*'
  s.exclude_files = 'AtlasSwift/Example/**/*.plist'
  s.swift_version = '4.2'
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.2' }
end
