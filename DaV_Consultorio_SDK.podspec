#
# Be sure to run `pod lib lint DaV_Consultorio_SDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DaV_Consultorio_SDK'
  s.version          = '1.0.12'
  s.summary          = 'Doutor ao Vivo - Consultorio Nativo'

  s.description      = <<-DESC
    Sala nativa ios de atendimento da Doutor ao Vivo
                       DESC

  s.homepage         = 'https://www.doutoraovivo.com.br'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Luciano Jesus LIma' => 'luciano@doutoraovivo.com.br' }

  s.source_files = s.name + '/Classes/*.swift'
  s.resource_bundle = { 'Assets' => s.name + '/Assets/**/*' }

  s.source           = {
    :git => 'https://github.com/doutoraovivo/dav-mobile-ios-component.git', :tag => s.version.to_s
  }
  
  s.platform = :ios, '9.0'
  s.swift_version = '4'

  s.frameworks = 'UIKit'
  s.static_framework = true
  s.dependency 'OpenTok', '~> 2.2'
  s.dependency 'Sentry', '~> 7'
  
  s.pod_target_xcconfig = {
      'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
    }
  
  s.user_target_xcconfig = {
      'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }
  
end
