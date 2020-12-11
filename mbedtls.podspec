Pod::Spec.new do |spec|
  spec.name         = "mbedtls"
  spec.version      = "2.7.17"
  spec.summary      = "An open source, portable, easy to use, readable and flexible SSL library."
  spec.homepage     = "https://tls.mbed.org"
  spec.license      = "libev"
  spec.author       = { "Sunnyyoung" => "iSunnyyoung@gmail.com" }
  spec.source       = { :http => "https://github.com/Sunnyyoung/mbedtls/releases/download/#{spec.version}/mbedtls.zip" }

  spec.ios.deployment_target = "8.0"
  spec.osx.deployment_target = "10.10"
  spec.watchos.deployment_target = "2.0"
  spec.tvos.deployment_target = "8.0"

  spec.vendored_frameworks = "mbedtls.xcframework"
end
