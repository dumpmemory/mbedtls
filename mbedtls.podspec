Pod::Spec.new do |spec|
  spec.name         = "mbedtls"
  spec.version      = "2.25.0"
  spec.summary      = "An open source, portable, easy to use, readable and flexible SSL library."
  spec.homepage     = "https://tls.mbed.org"
  spec.license      = "libev"
  spec.author       = { "Sunnyyoung" => "iSunnyyoung@gmail.com" }
  spec.source       = { :http => "https://github.com/ARMmbed/mbedtls.git", :tag => "#{spec.version}" }

  spec.requires_arc = false
  spec.header_dir = "mbedtls"
  spec.public_header_files = "mbedtls/include/**/*.h"
  spec.source_files = [
    "mbedtls/library/**/*.c",
    "mbedtls/include/**/*.h"
  ]
  spec.pod_target_xcconfig = {
    "HEADER_SEARCH_PATHS" => "\"${PODS_TARGET_SRCROOT}/include\"",
    "CLANG_WARN_DOCUMENTATION_COMMENTS" => "NO"
  }
end
