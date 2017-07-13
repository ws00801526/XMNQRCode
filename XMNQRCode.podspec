#
#  Be sure to run `pod spec lint XMNQRCode.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "XMNQRCode"
  s.version      = "0.2.2"
  s.summary      = "使用系统api实现二维码扫描功能,二维码图片识别功能, 增加二维码,条形码生成功能"
  s.homepage     = "https://github.com/ws00801526/XMNQRCode"
  s.license      = "MIT"
  s.author       = { "XMFraker" => "3057600441@qq.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/ws00801526/XMNQRCode.git", :tag => "#{s.version}" }
  s.source_files  = "XMNQRCode/Classes/*.{h,m}"
  s.public_header_files = 'XMNQRCode/Classes/XMNQRCode.h','XMNQRCode/Classes/XMNQRCodeBuilder.h','XMNQRCode/Classes/XMNQRCodeReaderController.h'
  s.resource  = "XMNQRCode/Resources/*.{png,jpg}"
  s.requires_arc = true
  s.ios.frameworks = 'CoreImage'
end
