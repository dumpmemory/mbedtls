#! /bin/sh

export ROOT="$(pwd)"
export SRC="$(pwd)/mbedtls"

export PREFIX="$(pwd)/build"
export MACOS_ARM64_PREFIX="${PREFIX}/tmp/macos-arm64"
export MACOS_X86_64_PREFIX="${PREFIX}/tmp/macos-x86_64"
export IOS32_PREFIX="${PREFIX}/tmp/ios32"
export IOS32s_PREFIX="${PREFIX}/tmp/ios32s"
export IOS64_PREFIX="${PREFIX}/tmp/ios64"
export IOS_SIMULATOR_ARM64_PREFIX="${PREFIX}/tmp/ios-simulator-arm64"
export IOS_SIMULATOR_I386_PREFIX="${PREFIX}/tmp/ios-simulator-i386"
export IOS_SIMULATOR_X86_64_PREFIX="${PREFIX}/tmp/ios-simulator-x86_64"
export WATCHOS32_PREFIX="${PREFIX}/tmp/watchos32"
export WATCHOS64_32_PREFIX="${PREFIX}/tmp/watchos64_32"
export WATCHOS_SIMULATOR_ARM64_PREFIX="${PREFIX}/tmp/watchos-simulator-arm64"
export WATCHOS_SIMULATOR_I386_PREFIX="${PREFIX}/tmp/watchos-simulator-i386"
export WATCHOS_SIMULATOR_X86_64_PREFIX="${PREFIX}/tmp/watchos-simulator-x86_64"
export TVOS64_PREFIX="${PREFIX}/tmp/tvos64"
export TVOS_SIMULATOR_ARM64_PREFIX="${PREFIX}/tmp/tvos-simulator-arm64"
export TVOS_SIMULATOR_X86_64_PREFIX="${PREFIX}/tmp/tvos-simulator-x86_64"
export CATALYST_ARM64_PREFIX="${PREFIX}/tmp/catalyst-arm64"
export CATALYST_X86_64_PREFIX="${PREFIX}/tmp/catalyst-x86_64"
export LOG_FILE="${PREFIX}/build_log"
export XCODEDIR="$(xcode-select -p)"

export MACOS_VERSION_MIN=${MACOS_VERSION_MIN-"10.10"}
export IOS_SIMULATOR_VERSION_MIN=${IOS_SIMULATOR_VERSION_MIN-"8.0"}
export IOS_VERSION_MIN=${IOS_VERSION_MIN-"8.0"}
export WATCHOS_SIMULATOR_VERSION_MIN=${WATCHOS_SIMULATOR_VERSION_MIN-"2.0"}
export WATCHOS_VERSION_MIN=${WATCHOS_VERSION_MIN-"2.0"}
export TVOS_SIMULATOR_VERSION_MIN=${TVOS_SIMULATOR_VERSION_MIN-"8.0"}
export TVOS_VERSION_MIN=${TVOS_VERSION_MIN-"8.0"}

echo "Buiding..."

APPLE_SILICON_SUPPORTED=false
echo 'int main(void){return 0;}' >comptest.c && cc --target=arm64-macos comptest.c 2>/dev/null && APPLE_SILICON_SUPPORTED=true
rm -f comptest.c
rm -f a.out

NPROCESSORS=$(getconf NPROCESSORS_ONLN 2>/dev/null || getconf _NPROCESSORS_ONLN 2>/dev/null)
PROCESSORS=${NPROCESSORS:-3}

build_macos() {
  export BASEDIR="${XCODEDIR}/Platforms/MacOSX.platform/Developer"
  export PATH="${BASEDIR}/usr/bin:$BASEDIR/usr/sbin:$PATH"

  ## macOS arm64
  if [ "$APPLE_SILICON_SUPPORTED" = "true" ]; then
    export CFLAGS="-O2 -arch arm64 -mmacosx-version-min=${MACOS_VERSION_MIN}"
    export LDFLAGS="-arch arm64 -mmacosx-version-min=${MACOS_VERSION_MIN}"

    mkdir -p ${MACOS_ARM64_PREFIX} && cd ${MACOS_ARM64_PREFIX}
    cmake -DENABLE_PROGRAMS=Off -DENABLE_TESTING=Off ${SRC}
    cmake --build ${MACOS_ARM64_PREFIX} --parallel ${PROCESSORS}
    cmake --install ${MACOS_ARM64_PREFIX} --prefix ${MACOS_ARM64_PREFIX}
  fi

  ## macOS x86_64
  export CFLAGS="-O2 -arch x86_64 -mmacosx-version-min=${MACOS_VERSION_MIN}"
  export LDFLAGS="-arch x86_64 -mmacosx-version-min=${MACOS_VERSION_MIN}"

  mkdir -p ${MACOS_X86_64_PREFIX} && cd ${MACOS_X86_64_PREFIX}
  cmake -DENABLE_PROGRAMS=Off -DENABLE_TESTING=Off ${SRC}
  cmake --build ${MACOS_X86_64_PREFIX} --parallel ${PROCESSORS}
  cmake --install ${MACOS_X86_64_PREFIX} --prefix ${MACOS_X86_64_PREFIX}
}

build_ios() {
  export BASEDIR="${XCODEDIR}/Platforms/iPhoneOS.platform/Developer"
  export PATH="${BASEDIR}/usr/bin:$BASEDIR/usr/sbin:$PATH"
  export SDK="${BASEDIR}/SDKs/iPhoneOS.sdk"

  ## 32-bit iOS
  export CFLAGS="-fembed-bitcode -O2 -mthumb -arch armv7 -isysroot ${SDK} -mios-version-min=${IOS_VERSION_MIN}"
  export LDFLAGS="-fembed-bitcode -mthumb -arch armv7 -isysroot ${SDK} -mios-version-min=${IOS_VERSION_MIN}"

  mkdir -p ${IOS32_PREFIX} && cd ${IOS32_PREFIX}
  cmake -DENABLE_PROGRAMS=Off -DENABLE_TESTING=Off ${SRC}
  cmake --build ${IOS32_PREFIX} --parallel ${PROCESSORS}
  cmake --install ${IOS32_PREFIX} --prefix ${IOS32_PREFIX}

  ## 32-bit armv7s iOS
  export CFLAGS="-fembed-bitcode -O2 -mthumb -arch armv7s -isysroot ${SDK} -mios-version-min=${IOS_VERSION_MIN}"
  export LDFLAGS="-fembed-bitcode -mthumb -arch armv7s -isysroot ${SDK} -mios-version-min=${IOS_VERSION_MIN}"

  mkdir -p ${IOS32s_PREFIX} && cd ${IOS32s_PREFIX}
  cmake -DENABLE_PROGRAMS=Off -DENABLE_TESTING=Off ${SRC}
  cmake --build ${IOS32s_PREFIX} --parallel ${PROCESSORS}
  cmake --install ${IOS32s_PREFIX} --prefix ${IOS32s_PREFIX}

  ## 64-bit iOS
  export CFLAGS="-fembed-bitcode -O2 -arch arm64 -isysroot ${SDK} -mios-version-min=${IOS_VERSION_MIN}"
  export LDFLAGS="-fembed-bitcode -arch arm64 -isysroot ${SDK} -mios-version-min=${IOS_VERSION_MIN}"

  mkdir -p ${IOS64_PREFIX} && cd ${IOS64_PREFIX}
  cmake -DENABLE_PROGRAMS=Off -DENABLE_TESTING=Off ${SRC}
  cmake --build ${IOS64_PREFIX} --parallel ${PROCESSORS}
  cmake --install ${IOS64_PREFIX} --prefix ${IOS64_PREFIX}
}

build_ios_simulator() {
  export BASEDIR="${XCODEDIR}/Platforms/iPhoneSimulator.platform/Developer"
  export PATH="${BASEDIR}/usr/bin:$BASEDIR/usr/sbin:$PATH"
  export SDK="${BASEDIR}/SDKs/iPhoneSimulator.sdk"

  ## arm64 simulator
  if [ "$APPLE_SILICON_SUPPORTED" = "true" ]; then
    export CFLAGS="-fembed-bitcode -O2 -arch arm64 -isysroot ${SDK} -mios-simulator-version-min=${IOS_SIMULATOR_VERSION_MIN}"
    export LDFLAGS="-fembed-bitcode -arch arm64 -isysroot ${SDK} -mios-simulator-version-min=${IOS_SIMULATOR_VERSION_MIN}"

    mkdir -p ${IOS_SIMULATOR_ARM64_PREFIX} && cd ${IOS_SIMULATOR_ARM64_PREFIX}
    cmake -DENABLE_PROGRAMS=Off -DENABLE_TESTING=Off ${SRC}
    cmake --build ${IOS_SIMULATOR_ARM64_PREFIX} --parallel ${PROCESSORS}
    cmake --install ${IOS_SIMULATOR_ARM64_PREFIX} --prefix ${IOS_SIMULATOR_ARM64_PREFIX}
  fi

  ## i386 simulator
  export CFLAGS="-fembed-bitcode -O2 -arch i386 -isysroot ${SDK} -mios-simulator-version-min=${IOS_SIMULATOR_VERSION_MIN}"
  export LDFLAGS="-fembed-bitcode -arch i386 -isysroot ${SDK} -mios-simulator-version-min=${IOS_SIMULATOR_VERSION_MIN}"

  mkdir -p ${IOS_SIMULATOR_I386_PREFIX} && cd ${IOS_SIMULATOR_I386_PREFIX}
  cmake -DENABLE_PROGRAMS=Off -DENABLE_TESTING=Off ${SRC}
  cmake --build ${IOS_SIMULATOR_I386_PREFIX} --parallel ${PROCESSORS}
  cmake --install ${IOS_SIMULATOR_I386_PREFIX} --prefix ${IOS_SIMULATOR_I386_PREFIX}

  ## x86_64 simulator
  export CFLAGS="-fembed-bitcode -O2 -arch x86_64 -isysroot ${SDK} -mios-simulator-version-min=${IOS_SIMULATOR_VERSION_MIN}"
  export LDFLAGS="-fembed-bitcode -arch x86_64 -isysroot ${SDK} -mios-simulator-version-min=${IOS_SIMULATOR_VERSION_MIN}"

  mkdir -p ${IOS_SIMULATOR_X86_64_PREFIX} && cd ${IOS_SIMULATOR_X86_64_PREFIX}
  cmake -DENABLE_PROGRAMS=Off -DENABLE_TESTING=Off ${SRC}
  cmake --build ${IOS_SIMULATOR_X86_64_PREFIX} --parallel ${PROCESSORS}
  cmake --install ${IOS_SIMULATOR_X86_64_PREFIX} --prefix ${IOS_SIMULATOR_X86_64_PREFIX}
}

build_watchos() {
  export BASEDIR="${XCODEDIR}/Platforms/WatchOS.platform/Developer"
  export PATH="${BASEDIR}/usr/bin:$BASEDIR/usr/sbin:$PATH"
  export SDK="${BASEDIR}/SDKs/WatchOS.sdk"

  # 32-bit watchOS
  export CFLAGS="-fembed-bitcode -O2 -mthumb -arch armv7k -isysroot ${SDK} -mwatchos-version-min=${WATCHOS_VERSION_MIN}"
  export LDFLAGS="-fembed-bitcode -mthumb -arch armv7k -isysroot ${SDK} -mwatchos-version-min=${WATCHOS_VERSION_MIN}"

  mkdir -p ${WATCHOS32_PREFIX} && cd ${WATCHOS32_PREFIX}
  cmake -DENABLE_PROGRAMS=Off -DENABLE_TESTING=Off ${SRC}
  cmake --build ${WATCHOS32_PREFIX} --parallel ${PROCESSORS}
  cmake --install ${WATCHOS32_PREFIX} --prefix ${WATCHOS32_PREFIX}

  ## 64-bit arm64_32 watchOS
  export CFLAGS="-fembed-bitcode -O2 -mthumb -arch arm64_32 -isysroot ${SDK} -mwatchos-version-min=${WATCHOS_VERSION_MIN}"
  export LDFLAGS="-fembed-bitcode -mthumb -arch arm64_32 -isysroot ${SDK} -mwatchos-version-min=${WATCHOS_VERSION_MIN}"

  mkdir -p ${WATCHOS64_32_PREFIX} && cd ${WATCHOS64_32_PREFIX}
  cmake -DENABLE_PROGRAMS=Off -DENABLE_TESTING=Off ${SRC}
  cmake --build ${WATCHOS64_32_PREFIX} --parallel ${PROCESSORS}
  cmake --install ${WATCHOS64_32_PREFIX} --prefix ${WATCHOS64_32_PREFIX}
}

build_watchos_simulator() {
  export BASEDIR="${XCODEDIR}/Platforms/WatchSimulator.platform/Developer"
  export PATH="${BASEDIR}/usr/bin:$BASEDIR/usr/sbin:$PATH"
  export SDK="${BASEDIR}/SDKs/WatchSimulator.sdk"

  ## arm64 simulator
  if [ "$APPLE_SILICON_SUPPORTED" = "true" ]; then
    export CFLAGS="-fembed-bitcode -O2 -arch arm64 -isysroot ${SDK} -mwatchos-simulator-version-min=${WATCHOS_SIMULATOR_VERSION_MIN}"
    export LDFLAGS="-fembed-bitcode -arch arm64 -isysroot ${SDK} -mwatchos-simulator-version-min=${WATCHOS_SIMULATOR_VERSION_MIN}"

    mkdir -p ${WATCHOS_SIMULATOR_ARM64_PREFIX} && cd ${WATCHOS_SIMULATOR_ARM64_PREFIX}
    cmake -DENABLE_PROGRAMS=Off -DENABLE_TESTING=Off ${SRC}
    cmake --build ${WATCHOS_SIMULATOR_ARM64_PREFIX} --parallel ${PROCESSORS}
    cmake --install ${WATCHOS_SIMULATOR_ARM64_PREFIX} --prefix ${WATCHOS_SIMULATOR_ARM64_PREFIX}
  fi

  ## i386 simulator
  export CFLAGS="-fembed-bitcode -O2 -arch i386 -isysroot ${SDK} -mwatchos-simulator-version-min=${WATCHOS_SIMULATOR_VERSION_MIN}"
  export LDFLAGS="-fembed-bitcode -arch i386 -isysroot ${SDK} -mwatchos-simulator-version-min=${WATCHOS_SIMULATOR_VERSION_MIN}"

  mkdir -p ${WATCHOS_SIMULATOR_I386_PREFIX} && cd ${WATCHOS_SIMULATOR_I386_PREFIX}
  cmake -DENABLE_PROGRAMS=Off -DENABLE_TESTING=Off ${SRC}
  cmake --build ${WATCHOS_SIMULATOR_I386_PREFIX} --parallel ${PROCESSORS}
  cmake --install ${WATCHOS_SIMULATOR_I386_PREFIX} --prefix ${WATCHOS_SIMULATOR_I386_PREFIX}

  ## x86_64 simulator
  export CFLAGS="-fembed-bitcode -O2 -arch x86_64 -isysroot ${SDK} -mwatchos-simulator-version-min=${WATCHOS_SIMULATOR_VERSION_MIN}"
  export LDFLAGS="-fembed-bitcode -arch x86_64 -isysroot ${SDK} -mwatchos-simulator-version-min=${WATCHOS_SIMULATOR_VERSION_MIN}"

  mkdir -p ${WATCHOS_SIMULATOR_X86_64_PREFIX} && cd ${WATCHOS_SIMULATOR_X86_64_PREFIX}
  cmake -DENABLE_PROGRAMS=Off -DENABLE_TESTING=Off ${SRC}
  cmake --build ${WATCHOS_SIMULATOR_X86_64_PREFIX} --parallel ${PROCESSORS}
  cmake --install ${WATCHOS_SIMULATOR_X86_64_PREFIX} --prefix ${WATCHOS_SIMULATOR_X86_64_PREFIX}
}

build_tvos() {
  export BASEDIR="${XCODEDIR}/Platforms/AppleTVOS.platform/Developer"
  export PATH="${BASEDIR}/usr/bin:$BASEDIR/usr/sbin:$PATH"
  export SDK="${BASEDIR}/SDKs/AppleTVOS.sdk"

  ## 64-bit tvOS
  export CFLAGS="-fembed-bitcode -O2 -arch arm64 -isysroot ${SDK} -mtvos-version-min=${TVOS_VERSION_MIN}"
  export LDFLAGS="-fembed-bitcode -arch arm64 -isysroot ${SDK} -mtvos-version-min=${TVOS_VERSION_MIN}"

  mkdir -p ${TVOS64_PREFIX} && cd ${TVOS64_PREFIX}
  cmake -DENABLE_PROGRAMS=Off -DENABLE_TESTING=Off ${SRC}
  cmake --build ${TVOS64_PREFIX} --parallel ${PROCESSORS}
  cmake --install ${TVOS64_PREFIX} --prefix ${TVOS64_PREFIX}
}

build_tvos_simulator() {
  export BASEDIR="${XCODEDIR}/Platforms/AppleTVSimulator.platform/Developer"
  export PATH="${BASEDIR}/usr/bin:$BASEDIR/usr/sbin:$PATH"
  export SDK="${BASEDIR}/SDKs/AppleTVSimulator.sdk"

  ## arm64 simulator
  if [ "$APPLE_SILICON_SUPPORTED" = "true" ]; then
    export CFLAGS="-fembed-bitcode -O2 -arch arm64 -isysroot ${SDK} -mtvos-simulator-version-min=${TVOS_SIMULATOR_VERSION_MIN}"
    export LDFLAGS="-fembed-bitcode -arch arm64 -isysroot ${SDK} -mtvos-simulator-version-min=${TVOS_SIMULATOR_VERSION_MIN}"

    mkdir -p ${TVOS_SIMULATOR_ARM64_PREFIX} && cd ${TVOS_SIMULATOR_ARM64_PREFIX}
    cmake -DENABLE_PROGRAMS=Off -DENABLE_TESTING=Off ${SRC}
    cmake --build ${TVOS_SIMULATOR_ARM64_PREFIX} --parallel ${PROCESSORS}
    cmake --install ${TVOS_SIMULATOR_ARM64_PREFIX} --prefix ${TVOS_SIMULATOR_ARM64_PREFIX}
  fi

  ## x86_64 simulator
  export CFLAGS="-fembed-bitcode -O2 -arch x86_64 -isysroot ${SDK} -mtvos-simulator-version-min=${TVOS_SIMULATOR_VERSION_MIN}"
  export LDFLAGS="-fembed-bitcode -arch x86_64 -isysroot ${SDK} -mtvos-simulator-version-min=${TVOS_SIMULATOR_VERSION_MIN}"

  mkdir -p ${TVOS_SIMULATOR_X86_64_PREFIX} && cd ${TVOS_SIMULATOR_X86_64_PREFIX}
  cmake -DENABLE_PROGRAMS=Off -DENABLE_TESTING=Off ${SRC}
  cmake --build ${TVOS_SIMULATOR_X86_64_PREFIX} --parallel ${PROCESSORS}
  cmake --install ${TVOS_SIMULATOR_X86_64_PREFIX} --prefix ${TVOS_SIMULATOR_X86_64_PREFIX}
}

build_catalyst() {
  export BASEDIR="${XCODEDIR}/Platforms/MacOSX.platform/Developer"
  export PATH="${BASEDIR}/usr/bin:$BASEDIR/usr/sbin:$PATH"
  export SDK="${BASEDIR}/SDKs/MacOSX.sdk"

  ## arm64 catalyst
  if [ "$APPLE_SILICON_SUPPORTED" = "true" ]; then
    export CFLAGS="-O2 -arch arm64 -target arm64-apple-ios13.0-macabi -isysroot ${SDK}"
    export LDFLAGS="-arch arm64 -target arm64-apple-ios13.0-macabi -isysroot ${SDK}"

    mkdir -p ${CATALYST_ARM64_PREFIX} && cd ${CATALYST_ARM64_PREFIX}
    cmake -DENABLE_PROGRAMS=Off -DENABLE_TESTING=Off ${SRC}
    cmake --build ${CATALYST_ARM64_PREFIX} --parallel ${PROCESSORS}
    cmake --install ${CATALYST_ARM64_PREFIX} --prefix ${CATALYST_ARM64_PREFIX}
  fi

  ## x86_64 catalyst
  export CFLAGS="-O2 -arch x86_64 -target x86_64-apple-ios13.0-macabi -isysroot ${SDK}"
  export LDFLAGS="-arch x86_64 -target x86_64-apple-ios13.0-macabi -isysroot ${SDK}"

  mkdir -p ${CATALYST_X86_64_PREFIX} && cd ${CATALYST_X86_64_PREFIX}
  cmake -DENABLE_PROGRAMS=Off -DENABLE_TESTING=Off ${SRC}
  cmake --build ${CATALYST_X86_64_PREFIX} --parallel ${PROCESSORS}
  cmake --install ${CATALYST_X86_64_PREFIX} --prefix ${CATALYST_X86_64_PREFIX}
}

mkdir -p ${PREFIX}
echo "Building for macOS..."
build_macos >"$LOG_FILE" 2>&1 || exit 1
echo "Building for iOS..."
build_ios >"$LOG_FILE" 2>&1 || exit 1
echo "Building for the iOS simulator..."
build_ios_simulator >"$LOG_FILE" 2>&1 || exit 1
echo "Building for watchOS..."
build_watchos >"$LOG_FILE" 2>&1 || exit 1
echo "Building for the watchOS simulator..."
build_watchos_simulator >"$LOG_FILE" 2>&1 || exit 1
echo "Building for tvOS..."
build_tvos >"$LOG_FILE" 2>&1 || exit 1
echo "Building for the tvOS simulator..."
build_tvos_simulator >"$LOG_FILE" 2>&1 || exit 1
echo "Building for Catalyst..."
build_catalyst >"$LOG_FILE" 2>&1 || exit 1

echo "Bundling macOS targets..."

mkdir -p "${PREFIX}/macos/lib"
cp -a "${MACOS_X86_64_PREFIX}/include/mbedtls" "${PREFIX}/macos/include"
for lib in libmbedcrypto.a libmbedtls.a libmbedx509.a; do
  if [ "$APPLE_SILICON_SUPPORTED" = "true" ]; then
    lipo -create \
      "${MACOS_ARM64_PREFIX}/lib/${lib}" \
      "${MACOS_X86_64_PREFIX}/lib/${lib}" \
      -output "${PREFIX}/macos/lib/${lib}" || exit 1
  else
    lipo -create \
      "${MACOS_X86_64_PREFIX}/lib/${lib}" \
      -output "${PREFIX}/macos/lib/${lib}" || exit 1
  fi
done
libtool -static -no_warning_for_no_symbols ${PREFIX}/macos/lib/*.a -o ${PREFIX}/macos/lib/libmbedtls.a

echo "Bundling iOS targets..."

mkdir -p "${PREFIX}/ios/lib"
cp -a "${IOS64_PREFIX}/include/mbedtls" "${PREFIX}/ios/include"
for lib in libmbedcrypto.a libmbedtls.a libmbedx509.a; do
  lipo -create \
    "$IOS32_PREFIX/lib/${lib}" \
    "$IOS32s_PREFIX/lib/${lib}" \
    "$IOS64_PREFIX/lib/${lib}" \
    -output "$PREFIX/ios/lib/${lib}"
done
libtool -static -no_warning_for_no_symbols $PREFIX/ios/lib/*.a -o $PREFIX/ios/lib/libmbedtls.a

echo "Bundling iOS simulators..."

mkdir -p "${PREFIX}/ios-simulators/lib"
cp -a "${IOS_SIMULATOR_X86_64_PREFIX}/include/mbedtls" "${PREFIX}/ios-simulators/include"
for lib in libmbedcrypto.a libmbedtls.a libmbedx509.a; do
  if [ "$APPLE_SILICON_SUPPORTED" = "true" ]; then
    lipo -create \
      "${IOS_SIMULATOR_ARM64_PREFIX}/lib/${lib}" \
      "${IOS_SIMULATOR_I386_PREFIX}/lib/${lib}" \
      "${IOS_SIMULATOR_X86_64_PREFIX}/lib/${lib}" \
      -output "${PREFIX}/ios-simulators/lib/${lib}" || exit 1
  else
    lipo -create \
      "${IOS_SIMULATOR_I386_PREFIX}/lib/${lib}" \
      "${IOS_SIMULATOR_X86_64_PREFIX}/lib/${lib}" \
      -output "${PREFIX}/ios-simulators/lib/${lib}" || exit 1
  fi
done
libtool -static -no_warning_for_no_symbols ${PREFIX}/ios-simulators/lib/*.a -o ${PREFIX}/ios-simulators/libmbedtls.a

echo "Bundling watchOS targets..."

mkdir -p "${PREFIX}/watchos/lib"
cp -a "${WATCHOS64_32_PREFIX}/include/mbedtls" "${PREFIX}/watchos/include"
for lib in libmbedcrypto.a libmbedtls.a libmbedx509.a; do
  lipo -create \
    "${WATCHOS32_PREFIX}/lib/${lib}" \
    "${WATCHOS64_32_PREFIX}/lib/${lib}" \
    -output "${PREFIX}/watchos/lib/${lib}"
done
libtool -static -no_warning_for_no_symbols ${PREFIX}/watchos/lib/*.a -o ${PREFIX}/watchos/lib/libmbedtls.a

echo "Bundling watchOS simulators..."

mkdir -p "${PREFIX}/watchos-simulators/lib"
cp -a "${WATCHOS_SIMULATOR_X86_64_PREFIX}/include/mbedtls" "${PREFIX}/watchos-simulators/include"
for lib in libmbedcrypto.a libmbedtls.a libmbedx509.a; do
  if [ "$APPLE_SILICON_SUPPORTED" = "true" ]; then
    lipo -create \
      "${WATCHOS_SIMULATOR_ARM64_PREFIX}/lib/${lib}" \
      "${WATCHOS_SIMULATOR_I386_PREFIX}/lib/${lib}" \
      "${WATCHOS_SIMULATOR_X86_64_PREFIX}/lib/${lib}" \
      -output "${PREFIX}/watchos-simulators/lib/${lib}"
  else
    lipo -create \
      "${WATCHOS_SIMULATOR_I386_PREFIX}/lib/${lib}" \
      "${WATCHOS_SIMULATOR_X86_64_PREFIX}/lib/${lib}" \
      -output "${PREFIX}/watchos-simulators/lib/${lib}"
  fi
done
libtool -static -no_warning_for_no_symbols ${PREFIX}/watchos-simulators/lib/*.a -o ${PREFIX}/watchos-simulators/lib/libmbedtls.a

echo "Bundling tvOS targets..."

mkdir -p "${PREFIX}/tvos/lib"
cp -a "${TVOS64_PREFIX}/include/mbedtls" "${PREFIX}/tvos/include"
for lib in libmbedcrypto.a libmbedtls.a libmbedx509.a; do
  lipo -create \
    "$TVOS64_PREFIX/lib/${lib}" \
    -output "$PREFIX/tvos/lib/${lib}"
done
libtool -static -no_warning_for_no_symbols $PREFIX/tvos/lib/*.a -o $PREFIX/tvos/lib/libmbedtls.a

echo "Bundling tvOS simulators..."

mkdir -p "${PREFIX}/tvos-simulators/lib"
cp -a "${TVOS_SIMULATOR_X86_64_PREFIX}/include/mbedtls" "${PREFIX}/tvos-simulators/include"
for lib in libmbedcrypto.a libmbedtls.a libmbedx509.a; do
  if [ "$APPLE_SILICON_SUPPORTED" = "true" ]; then
    lipo -create \
      "${TVOS_SIMULATOR_ARM64_PREFIX}/lib/${lib}" \
      "${TVOS_SIMULATOR_X86_64_PREFIX}/lib/${lib}" \
      -output "${PREFIX}/tvos-simulators/lib/${lib}" || exit 1
  else
    lipo -create \
      "${TVOS_SIMULATOR_X86_64_PREFIX}/lib/${lib}" \
      -output "${PREFIX}/tvos-simulators/lib/${lib}" || exit 1
  fi
done
libtool -static -no_warning_for_no_symbols ${PREFIX}/tvos-simulators/lib/*.a -o ${PREFIX}/tvos-simulators/lib/libmbedtls.a

echo "Bundling Catalyst targets..."

mkdir -p "${PREFIX}/catalyst/lib"
cp -a "${CATALYST_X86_64_PREFIX}/include/mbedtls" "${PREFIX}/catalyst/include"
for lib in libmbedcrypto.a libmbedtls.a libmbedx509.a; do
  if [ ! -f "${CATALYST_X86_64_PREFIX}/lib/${lib}" ]; then
    continue
  fi
  if [ "$APPLE_SILICON_SUPPORTED" = "true" ]; then
    lipo -create \
      "${CATALYST_ARM64_PREFIX}/lib/${lib}" \
      "${CATALYST_X86_64_PREFIX}/lib/${lib}" \
      -output "${PREFIX}/catalyst/lib/${lib}"
  else
    lipo -create \
      "${CATALYST_X86_64_PREFIX}/lib/${lib}" \
      -output "${PREFIX}/catalyst/lib/${lib}"
  fi
done
libtool -static -no_warning_for_no_symbols ${PREFIX}/catalyst/lib/*.a -o ${PREFIX}/catalyst/lib/libmbedtls.a

echo "Creating mbedtls.xcframework..."

XCFRAMEWORK_ARGS=""
for f in macos ios ios-simulators watchos watchos-simulators tvos tvos-simulators catalyst; do
  XCFRAMEWORK_ARGS="${XCFRAMEWORK_ARGS} -library ${PREFIX}/${f}/lib/libmbedtls.a"
  XCFRAMEWORK_ARGS="${XCFRAMEWORK_ARGS} -headers ${PREFIX}/${f}/include"
done
xcodebuild -create-xcframework ${XCFRAMEWORK_ARGS} -output "${PREFIX}/mbedtls.xcframework" >/dev/null

ls -l -- "$PREFIX/mbedtls.xcframework"

echo "Done!"

# Cleanup
rm -rf -- "$PREFIX/tmp"
