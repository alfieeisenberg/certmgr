#!/usr/bin/env bash

set -e
# set -x

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

pushd "${SCRIPT_DIR}/.."
ROOT_DIR="$PWD"
popd

PROJECT_NAME="OpenSSL"

# defaults: dynamic lib
LIB_TYPE=""
BUILD_TYPE="Release"
BUILD_FOR_DIST="YES"
XC_USER_DEFINED_VARS=""

while getopts ":sd" option; do
    case $option in
        d) # Build debug instead of release
            BUILD_TYPE="Debug"
            BUILD_FOR_DIST="NO"
            ;;
        s) # Build XCFramework as static instead of dynamic
            LIB_TYPE="MACH_O_TYPE=staticlib"
            ;;
   esac
done
COMMON_SETUP=" -project ${ROOT_DIR}/${PROJECT_NAME}.xcodeproj -configuration ${BUILD_TYPE} BUILD_LIBRARY_FOR_DISTRIBUTION=${BUILD_FOR_DIST} ${LIB_TYPE}"

FRAMEWORK_DIR="${ROOT_DIR}/Frameworks"

# Use this path so that our release artifacts show up next to the debug stuff from Xcode IDE
DERIVED_DATA_PATH="${ROOT_DIR}/DerivedData/${PROJECT_NAME}"
mkdir -p "${DERIVED_DATA_PATH}"

# macOS
xcrun xcodebuild build \
	${COMMON_SETUP} \
	-scheme "${PROJECT_NAME} (macOS)" \
	-derivedDataPath "${DERIVED_DATA_PATH}" \
	-destination 'generic/platform=macOS'

rm -rf "${FRAMEWORK_DIR}/macosx"
mkdir -p "${FRAMEWORK_DIR}/macosx"
ditto "${DERIVED_DATA_PATH}/Build/Products/Release/${PROJECT_NAME}.framework" "${FRAMEWORK_DIR}/macosx/${PROJECT_NAME}.framework"

# macOS Catalyst
xcrun xcodebuild build \
	${COMMON_SETUP} \
	-scheme "${PROJECT_NAME} (Catalyst)" \
	-derivedDataPath "${DERIVED_DATA_PATH}" \
	-destination 'generic/platform=macOS,variant=Mac Catalyst'

rm -rf "${FRAMEWORK_DIR}/macosx_catalyst"
mkdir -p "${FRAMEWORK_DIR}/macosx_catalyst"
ditto "${DERIVED_DATA_PATH}/Build/Products/Release-maccatalyst/${PROJECT_NAME}.framework" "${FRAMEWORK_DIR}/macosx_catalyst/${PROJECT_NAME}.framework"

# iOS
xcrun xcodebuild build \
	${COMMON_SETUP} \
	-scheme "${PROJECT_NAME} (iOS)" \
	-derivedDataPath "${DERIVED_DATA_PATH}" \
	-destination 'generic/platform=iOS'

rm -rf "${FRAMEWORK_DIR}/iphoneos"
mkdir -p "${FRAMEWORK_DIR}/iphoneos"
ditto "${DERIVED_DATA_PATH}/Build/Products/Release-iphoneos/${PROJECT_NAME}.framework" "${FRAMEWORK_DIR}/iphoneos/${PROJECT_NAME}.framework"

# iOS Simulator
xcrun xcodebuild build \
	${COMMON_SETUP} \
	-scheme "${PROJECT_NAME} (iOS Simulator)" \
	-derivedDataPath "${DERIVED_DATA_PATH}" \
	-destination 'generic/platform=iOS Simulator'

rm -rf "${FRAMEWORK_DIR}/iphonesimulator"
mkdir -p "${FRAMEWORK_DIR}/iphonesimulator"
ditto "${DERIVED_DATA_PATH}/Build/Products/Release-iphonesimulator/${PROJECT_NAME}.framework" "${FRAMEWORK_DIR}/iphonesimulator/${PROJECT_NAME}.framework"

# XCFramework
rm -rf "${FRAMEWORK_DIR}/${PROJECT_NAME}.xcframework"

xcrun xcodebuild -create-xcframework \
	-framework "${FRAMEWORK_DIR}/iphoneos/${PROJECT_NAME}.framework" \
	-framework "${FRAMEWORK_DIR}/iphonesimulator/${PROJECT_NAME}.framework" \
	-framework "${FRAMEWORK_DIR}/macosx/${PROJECT_NAME}.framework" \
	-framework "${FRAMEWORK_DIR}/macosx_catalyst/${PROJECT_NAME}.framework" \
	-output "${FRAMEWORK_DIR}/${PROJECT_NAME}.xcframework"

# Zip archive
pushd "${FRAMEWORK_DIR}"
zip --symlinks -r "./${PROJECT_NAME}.xcframework.zip" "./${PROJECT_NAME}.xcframework"
popd
