# Copyright (c) Facebook, Inc. and its affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))
version = package['version']



folly_compiler_flags = '-DFOLLY_NO_CONFIG -DFOLLY_MOBILE=1 -DFOLLY_USE_LIBCPP=1 -Wno-comma -Wno-shorten-64-to-32'
folly_version = '2021.06.28.00-v2'
boost_compiler_flags = '-Wno-documentation'

header_subspecs = {
  'CoreModulesHeaders'          => 'React/CoreModules/**/*.h',
  'RCTActionSheetHeaders'       => 'Libraries/ActionSheetIOS/*.h',
  'RCTAnimationHeaders'         => 'Libraries/NativeAnimation/{Drivers/*,Nodes/*,*}.{h}',
  'RCTBlobHeaders'              => 'Libraries/Blob/{ABI44_0_0RCTBlobManager,ABI44_0_0RCTFileReaderModule}.h',
  'RCTImageHeaders'             => 'Libraries/Image/*.h',
  'RCTLinkingHeaders'           => 'Libraries/LinkingIOS/*.h',
  'RCTNetworkHeaders'           => 'Libraries/Network/*.h',
  'RCTPushNotificationHeaders'  => 'Libraries/PushNotificationIOS/*.h',
  'RCTSettingsHeaders'          => 'Libraries/Settings/*.h',
  'RCTTextHeaders'              => 'Libraries/Text/**/*.h',
  'RCTVibrationHeaders'         => 'Libraries/Vibration/*.h',
}

Pod::Spec.new do |s|
  s.name                   = "ABI44_0_0React-Core"
  s.version                = version
  s.summary                = "The core of React Native."
  s.homepage               = "https://reactnative.dev/"
  s.license                = package["license"]
  s.author                 = "Facebook, Inc. and its affiliates"
  s.platforms              = { :ios => "10.0" }
  s.source                 = { :path => "." }
  s.resource_bundle        = { "ABI44_0_0AccessibilityResources" => ["React/AccessibilityResources/*.lproj"]}
  s.compiler_flags         = folly_compiler_flags + ' ' + boost_compiler_flags
  s.header_dir             = "ABI44_0_0React"
  s.framework              = "JavaScriptCore"
  s.library                = "stdc++"
  s.pod_target_xcconfig    = { "HEADER_SEARCH_PATHS" => "\"$(PODS_TARGET_SRCROOT)/ReactCommon\" \"$(PODS_ROOT)/boost\" \"$(PODS_ROOT)/DoubleConversion\" \"$(PODS_ROOT)/RCT-Folly\"", "DEFINES_MODULE" => "YES" }
  s.user_target_xcconfig   = { "HEADER_SEARCH_PATHS" => "\"$(PODS_ROOT)/Headers/Private/ABI44_0_0React-Core\""}
  s.default_subspec        = "Default"
  s.module_map             = "ABI44_0_0React-Core.modulemap"

  s.subspec "Default" do |ss|
    ss.source_files           = "React/**/*.{c,h,m,mm,S,cpp}"
    ss.exclude_files          = "React/CoreModules/**/*",
                                "React/DevSupport/**/*",
                                "React/Fabric/**/*",
                                "React/FBReactNativeSpec/**/*",
                                "React/Tests/**/*",
                                "React/Inspector/**/*"
    ss.private_header_files   = "React/Cxx*/*.h"
  end

  s.subspec "Hermes" do |ss|
    ss.private_header_files = "ReactCommon/hermes/executor/*.h", "ReactCommon/hermes/inspector/*.h", "ReactCommon/hermes/inspector/chrome/*.h", "ReactCommon/hermes/inspector/detail/*.h"
    ss.platforms = { :osx => "10.14", :ios => "10.0" }
    ss.source_files = "ReactCommon/hermes/executor/*.{cpp,h}",
                      "ReactCommon/hermes/inspector/*.{cpp,h}",
                      "ReactCommon/hermes/inspector/chrome/*.{cpp,h}",
                      "ReactCommon/hermes/inspector/detail/*.{cpp,h}"
    ss.pod_target_xcconfig = { "GCC_PREPROCESSOR_DEFINITIONS" => "HERMES_ENABLE_DEBUGGER=1" }
    ss.dependency "RCT-Folly/Futures"
    ss.dependency "hermes-engine"
  end

  s.subspec "DevSupport" do |ss|
    ss.source_files = "React/DevSupport/*.{h,mm,m}",
                      "React/Inspector/*.{h,mm,m}"

    ss.dependency "ABI44_0_0React-Core/Default", version
    ss.dependency "ABI44_0_0React-Core/RCTWebSocket", version
    ss.dependency "ABI44_0_0React-jsinspector", version
  end

  s.subspec "RCTWebSocket" do |ss|
    ss.source_files = "Libraries/WebSocket/*.{h,m}"
    ss.dependency "ABI44_0_0React-Core/Default", version
  end

  # Add a subspec containing just the headers for each
  # pod that should live under <React/*.h>
  header_subspecs.each do |name, headers|
    s.subspec name do |ss|
      ss.source_files = headers
      ss.dependency "ABI44_0_0React-Core/Default"
    end
  end

  s.dependency "RCT-Folly", folly_version
  s.dependency "ABI44_0_0React-cxxreact", version
  s.dependency "ABI44_0_0React-perflogger", version
  s.dependency "ABI44_0_0React-jsi", version
  s.dependency "ABI44_0_0React-jsiexecutor", version
  s.dependency "ABI44_0_0Yoga"
  s.dependency "glog"
end
