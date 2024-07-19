#!/usr/bin/env bash

# Yay shell scripting! This script builds a static version of
# OpenSSL for iOS and OSX that contains code for arm64, x86_64.

set -e
# set -x

BASE_PWD="$PWD"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

FWNAME="OpenSSL"
NUM_CPU=`sysctl -n hw.ncpu`

# Setup paths to stuff we need

if [[ -z $OPENSSL_VERSION ]]; then
 echo "OPENSSL_VERSION not set"
 exit 1
fi

export OPENSSL_LOCAL_CONFIG_DIR="${SCRIPT_DIR}/../config"


DEVELOPER=$(xcode-select --print-path)

export IPHONEOS_DEPLOYMENT_VERSION="11.0"
IPHONEOS_SDK=$(xcrun --sdk iphoneos --show-sdk-path)
IPHONESIMULATOR_SDK=$(xcrun --sdk iphonesimulator --show-sdk-path)
OSX_SDK=$(xcrun --sdk macosx --show-sdk-path)

export MACOSX_DEPLOYMENT_TARGET="10.14" # 

# Turn versions like 1.2.3 into numbers that can be compare by bash.
version()
{
   printf "%03d%03d%03d%03d" $(tr '.' ' ' <<<"$1");
}

configure() {
   local OS=$1
   local ARCH=$2
   local BUILD_DIR=$3
   local SRC_DIR=$4

   echo "Configuring for ${OS} ${ARCH}"

   local SDK=
   case "$OS" in
      iPhoneOS)
	 SDK="${IPHONEOS_SDK}"
	 ;;
      iPhoneSimulator)
	 SDK="${IPHONESIMULATOR_SDK}"
	 ;;
      MacOSX)
	 SDK="${OSX_SDK}"
	 ;;
      MacOSX_Catalyst)
	 SDK="${OSX_SDK}"
	 ;;
      *)
	 echo "Unsupported OS '${OS}'!" >&1
	 exit 1
	 ;;
   esac

   local PREFIX="${BUILD_DIR}/${OPENSSL_VERSION}-${OS}-${ARCH}"

   export CROSS_TOP="${SDK%%/SDKs/*}"
   export CROSS_SDK="${SDK##*/SDKs/}"
   if [ -z "$CROSS_TOP" -o -z "$CROSS_SDK" ]; then
      echo "Failed to parse SDK path '${SDK}'!" >&1
      exit 2
   fi
   

   if [ "$OS" == "MacOSX" ]; then
      ${SRC_DIR}/Configure macos-$ARCH no-asm no-shared --prefix="${PREFIX}" &> "${PREFIX}.config.log"
   elif [ "$OS" == "MacOSX_Catalyst" ]; then
      ${SRC_DIR}/Configure mac-catalyst-$ARCH no-asm no-shared --prefix="${PREFIX}" &> "${PREFIX}.config.log"
   elif [ "$OS" == "iPhoneSimulator" ]; then
      ${SRC_DIR}/Configure ios-sim-cross-$ARCH no-asm no-shared --prefix="${PREFIX}" &> "${PREFIX}.config.log"
   elif [ "$OS" == "iPhoneOS" ]; then
      ${SRC_DIR}/Configure ios-cross-$ARCH no-asm no-shared --prefix="${PREFIX}" &> "${PREFIX}.config.log"
   fi
}

fixHeaders() {
   local INCLUDE_PATH=$1
   local OPENSSL_PATH="${INCLUDE_PATH}/${FWNAME}"

   cp -f "${SCRIPT_DIR}/../shim/shim.h" "${OPENSSL_PATH}"

   # fix inttypes.h
   find "${OPENSSL_PATH}" -type f -name "*.h" -exec sed -i "" -e "s/include <inttypes\.h>/include <sys\/types\.h>/g" {} \;

   # fix RC4_INT redefinition
   echo find "${OPENSSL_PATH}" -type f -name "*.h" -exec sed -i "" -e "s/\#define RC4_INT unsigned char/\#if \!defined(RC4_INT)\n#define RC4_INT unsigned char\n\#endif\n/g" {} \;
   find "${OPENSSL_PATH}" -type f -name "*.h" -exec sed -i "" -e "s/\#define RC4_INT unsigned char/\#if \!defined(RC4_INT)\n#define RC4_INT unsigned char\n\#endif\n/g" {} \;
   find "${OPENSSL_PATH}" -type f -name "*.h" -exec sed -i "" -e "s/\#define RC4_INT unsigned int/\#if \!defined(RC4_INT)\n#define RC4_INT unsigned int\n\#endif\n/g" {} \;
   find "${OPENSSL_PATH}" -type f -name "*.h" -exec grep RC4_INT {} \; -ls

   # Update include "openssl/" to "OpenSSL/"
   grep -rl '#\s*include\s*<openssl' --include \*.h ${INCLUDE_PATH} | xargs -I@ sed -i '' -e 's/#[[:space:]]*include[[:space:]]*<openssl/#include <OpenSSL/gi' @
}

build()
{
   local ARCH=$1
   local OS=$2
   local BUILD_DIR=$3
   local TYPE=$4 # iphoneos/iphonesimulator/macosx/macosx_catalyst

   local SRC_DIR="${BUILD_DIR}/${FWNAME}-${OPENSSL_VERSION}-${TYPE}"
   local PREFIX="${BUILD_DIR}/${OPENSSL_VERSION}-${OS}-${ARCH}"

   mkdir -p "${SRC_DIR}"
   tar xzf "${SCRIPT_DIR}/../openssl-${OPENSSL_VERSION}.tar.gz" -C "${SRC_DIR}" --strip-components=1

   # Apply patches if needed
   local PATCH_FILE="${SCRIPT_DIR}/../patches/openssl-${OPENSSL_VERSION}.patch"
   if [ -f "$PATCH_FILE" ]; then
      patch -d "${SRC_DIR}" -p1 < $PATCH_FILE
   fi

   echo "Building for ${OS} ${ARCH}"

   # Change dir
   cd "${SRC_DIR}"

   # fix headers for Swift

   sed -ie "s/BIGNUM \*I,/BIGNUM \*i,/g" ${SRC_DIR}/crypto/rsa/rsa_local.h   

   configure "${OS}" $ARCH ${BUILD_DIR} ${SRC_DIR}

   LOG_PATH="${PREFIX}.build.log"
   echo "Building ${LOG_PATH}"
   make -j${NUM_CPU} &> ${LOG_PATH}
   make install &> ${LOG_PATH}
   cd ${BASE_PWD}

   # Add arch to library
   if [ -f "${SCRIPT_DIR}/../${TYPE}/lib/libcrypto.a" ]; then
      xcrun lipo "${SCRIPT_DIR}/../${TYPE}/lib/libcrypto.a" "${PREFIX}/lib/libcrypto.a" -create -output "${SCRIPT_DIR}/../${TYPE}/lib/libcrypto.a"
      xcrun lipo "${SCRIPT_DIR}/../${TYPE}/lib/libssl.a" "${PREFIX}/lib/libssl.a" -create -output "${SCRIPT_DIR}/../${TYPE}/lib/libssl.a"
   else
      cp "${PREFIX}/lib/libcrypto.a" "${SCRIPT_DIR}/../${TYPE}/lib/libcrypto.a"
      cp "${PREFIX}/lib/libssl.a" "${SCRIPT_DIR}/../${TYPE}/lib/libssl.a"
   fi

   rm -rf "${SRC_DIR}"
}

build_ios() {
   local TMP_BUILD_DIR=$( mktemp -d )

   # Clean up whatever was left from our previous build
   rm -rf "${SCRIPT_DIR}"/../{iphoneos/include,iphoneos/lib}
   mkdir -p "${SCRIPT_DIR}"/../{iphoneos/include,iphoneos/lib}

   build "arm64" "iPhoneOS" ${TMP_BUILD_DIR} "iphoneos"

   # Copy headers from *any* build
   ditto "${TMP_BUILD_DIR}/${OPENSSL_VERSION}-iPhoneOS-arm64/include/openssl" "${SCRIPT_DIR}/../iphoneos/include/${FWNAME}"

   # Create opensslconf.h with info from each build
   local OPENSSLCONF_PATH="${SCRIPT_DIR}/../iphoneos/include/${FWNAME}/opensslconf.h"
   echo "#if defined(__APPLE__) && defined (__x86_64__)" >> ${OPENSSLCONF_PATH}
   # not supported
   echo "#elif defined(__APPLE__) && defined (__arm64__)" >> ${OPENSSLCONF_PATH}
   cat ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-iPhoneOS-arm64/include/openssl/opensslconf.h >> ${OPENSSLCONF_PATH}
   echo "#endif" >> ${OPENSSLCONF_PATH}

   # Fix headers
   fixHeaders "${SCRIPT_DIR}/../iphoneos/include"

   rm -rf ${TMP_BUILD_DIR}
}

build_ios_simulator() {
   local TMP_BUILD_DIR=$( mktemp -d )

   # Clean up whatever was left from our previous build
   rm -rf "${SCRIPT_DIR}"/../{iphonesimulator/include,iphonesimulator/lib}
   mkdir -p "${SCRIPT_DIR}"/../{iphonesimulator/include,iphonesimulator/lib}

   build "x86_64" "iPhoneSimulator" ${TMP_BUILD_DIR} "iphonesimulator"
   build "arm64" "iPhoneSimulator" ${TMP_BUILD_DIR} "iphonesimulator"

   # Copy headers from *any* build
   ditto "${TMP_BUILD_DIR}/${OPENSSL_VERSION}-iPhoneSimulator-arm64/include/openssl" "${SCRIPT_DIR}/../iphonesimulator/include/${FWNAME}"

   # Create opensslconf.h with info from each build
   local OPENSSLCONF_PATH="${SCRIPT_DIR}/../iphonesimulator/include/${FWNAME}/opensslconf.h"
   echo "#if defined(__APPLE__) && defined (__x86_64__)" >> ${OPENSSLCONF_PATH}
   cat ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-iPhoneSimulator-x86_64/include/openssl/opensslconf.h >> ${OPENSSLCONF_PATH}
   echo "#elif defined(__APPLE__) && defined (__arm64__)" >> ${OPENSSLCONF_PATH}
   cat ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-iPhoneSimulator-arm64/include/openssl/opensslconf.h >> ${OPENSSLCONF_PATH}
   echo "#endif" >> ${OPENSSLCONF_PATH}

   # Fix headers
   fixHeaders "${SCRIPT_DIR}/../iphonesimulator/include"

   rm -rf ${TMP_BUILD_DIR}
}

build_macos() {
   local TMP_BUILD_DIR=$( mktemp -d )

   # Clean up whatever was left from our previous build
   rm -rf "${SCRIPT_DIR}"/../{macosx/include,macosx/lib}
   mkdir -p "${SCRIPT_DIR}"/../{macosx/include,macosx/lib}

   build "x86_64" "MacOSX" ${TMP_BUILD_DIR} "macosx"
   build "arm64" "MacOSX" ${TMP_BUILD_DIR} "macosx"

   # Copy headers from *any* build
   ditto ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-MacOSX-x86_64/include/openssl "${SCRIPT_DIR}/../macosx/include/${FWNAME}"

   # Create opensslconf.h with info from each build
   local OPENSSLCONF_PATH="${SCRIPT_DIR}/../macosx/include/${FWNAME}/opensslconf.h"
   echo "#if defined(__APPLE__) && defined (__x86_64__)" >> ${OPENSSLCONF_PATH}
   cat ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-MacOSX-x86_64/include/openssl/opensslconf.h >> ${OPENSSLCONF_PATH}
   echo "#elif defined(__APPLE__) && defined (__arm64__)" >> ${OPENSSLCONF_PATH}
   cat ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-MacOSX-arm64/include/openssl/opensslconf.h >> ${OPENSSLCONF_PATH}
   echo "#endif" >> ${OPENSSLCONF_PATH}
   
   # Fix headers
   fixHeaders "${SCRIPT_DIR}/../macosx/include"

   rm -rf ${TMP_BUILD_DIR}
}

build_catalyst() {
   local TMP_BUILD_DIR=$( mktemp -d )

   # Clean up whatever was left from our previous build
   rm -rf "${SCRIPT_DIR}"/../{macosx_catalyst/include,macosx_catalyst/lib}
   mkdir -p "${SCRIPT_DIR}"/../{macosx_catalyst/include,macosx_catalyst/lib}

   build "x86_64" "MacOSX_Catalyst" ${TMP_BUILD_DIR} "macosx_catalyst"
   build "arm64" "MacOSX_Catalyst" ${TMP_BUILD_DIR} "macosx_catalyst"

   # Copy headers from *any* build
   ditto ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-MacOSX_Catalyst-x86_64/include/openssl "${SCRIPT_DIR}/../macosx_catalyst/include/${FWNAME}"

   # Create opensslconf.h with info from each build
   local OPENSSLCONF_PATH="${SCRIPT_DIR}/../macosx_catalyst/include/${FWNAME}/opensslconf.h"
   echo "#if defined(__APPLE__) && defined (__x86_64__)" >> ${OPENSSLCONF_PATH}
   cat ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-MacOSX_Catalyst-x86_64/include/openssl/opensslconf.h >> ${OPENSSLCONF_PATH}
   echo "#elif defined(__APPLE__) && defined (__arm64__)" >> ${OPENSSLCONF_PATH}
   cat ${TMP_BUILD_DIR}/${OPENSSL_VERSION}-MacOSX_Catalyst-arm64/include/openssl/opensslconf.h >> ${OPENSSLCONF_PATH}
   echo "#endif" >> ${OPENSSLCONF_PATH}

   # Fix headers
   fixHeaders "${SCRIPT_DIR}/../macosx_catalyst/include"

   rm -rf ${TMP_BUILD_DIR}
}

# Start

if [ ! -f "${SCRIPT_DIR}/../openssl-${OPENSSL_VERSION}.tar.gz" ]; then
   curl -fL "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz" -o "${SCRIPT_DIR}/../openssl-${OPENSSL_VERSION}.tar.gz"
   curl -fL "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz.sha256" -o "${SCRIPT_DIR}/../openssl-${OPENSSL_VERSION}.tar.gz.sha256"
   DIGEST=$( cat ${SCRIPT_DIR}/../openssl-${OPENSSL_VERSION}.tar.gz.sha256 )

   if [[ "$(shasum -a 256 "openssl-${OPENSSL_VERSION}.tar.gz" | awk '{ print " "$1}')" != "${DIGEST}" ]]
   then
      echo "openssl-${OPENSSL_VERSION}.tar.gz: checksum mismatch"
      exit 1
   fi
   rm -f "${SCRIPT_DIR}/../openssl-${OPENSSL_VERSION}.tar.gz.sha256"
fi

build_ios
build_ios_simulator
build_macos
build_catalyst