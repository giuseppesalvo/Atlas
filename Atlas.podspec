Pod::Spec.new do |s|
  s.name             = 'Atlas'
  s.version          = '0.0.1'
  s.summary          = 'Atlas is a redux store for your swift apps without the reducer layer'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
                        Atlas is a redux store for your swift apps without the reducer layer
                        DESC
  s.homepage         = 'https://github.com/giuseppesalvo/atlas'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Giuseppe' => 'giuseppesalvo@outlook.it' }
  s.source           = { :git => 'https://github.com/giuseppesalvo/Atlas.git', :tag => s.version.to_s }
  s.social_media_url = 'https://github.com/giuseppesalvo'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
  s.watchos.deployment_target = '2.0'
  s.tvos.deployment_target = '9.0'
  s.source_files = 'Atlas/Classes/**/*'
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.1' }
end
