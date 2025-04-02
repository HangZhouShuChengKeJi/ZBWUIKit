
Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "ZBWUIKit"
  s.version      = "0.3.5"
  s.summary      = "响应链上获取指定的vc。标签控件、格网控件等等"

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description  = <<-DESC
                    响应链上获取指定的vc。标签控件、格网控件等等。
                   DESC

  s.homepage     = "https://github.com/HangZhouShuChengKeJi/ZBWUIKit"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Licensing your code is important. See http://choosealicense.com for more info.
  #  CocoaPods will detect a license file if there is a named LICENSE*
  #  Popular ones are 'MIT', 'BSD' and 'Apache License, Version 2.0'.
  #

  s.license      = "BSD"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }

  s.author             = { "bwzhu" => "bowen.zhu@91chengguo.com" }

  s.source       = { :git => "https://github.com/HangZhouShuChengKeJi/ZBWUIKit.git", :tag => "#{s.version}" }

  s.platform     = :ios, "9.0"

  s.source_files  = "ZBWUIKit", "ZBWUIKit/*.{h,m,mm}" ,"ZBWUIKit/**/*.{h,m,mm}"

  s.prefix_header_file = "ZBWUIKit/ZBWUIKit-prefix.pch"

  # s.exclude_files = "Classes/Exclude"

  # s.public_header_files = "Classes/**/*.h"

  # s.subspec 'CustomViews' do |coustomviewsSpec|
  #   coustomviewsSpec.source_files = "ZBWUIKit/CustomViews/**/*.{h,m,mm}"
  # end

  # s.subspec 'ViewControllers' do |viewControllersSpec|
  #   viewControllersSpec.source_files = "ZBWUIKit/ViewControllers/**/*.{h,m,mm}"
  # end

  # s.subspec 'Category' do |categoryS|
  #   categoryS.source_files = "ZBWUIKit/Category/*.*","ZBWUIKit/Category/**/*.{h,m,mm}"
  # end

  # s.requires_arc = true
  # s.pod_target_xcconfig = { 'VALID_ARCHS' => 'x86_64 armv7 arm64' }

  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  # s.framework  = "SomeFramework"
  # s.frameworks = "SomeFramework", "AnotherFramework"

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  s.dependency "ZBWCategories", '~> 0.1.8'
  s.dependency 'MJRefresh', '~> 3.7.5'
  s.dependency 'ZBWUISignal'
  s.dependency 'lottie-ios-OC'

end
