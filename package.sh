#!/bin/bash
set -euo pipefail

APP_NAME="mec"
IDENTIFIER="com.Code-Win.mec"
DIST_DIR="dist"
APP_BUNDLE="${DIST_DIR}/${APP_NAME}.app"
CONTENTS_DIR="${APP_BUNDLE}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

# 1. Clean and Build
echo "Building ${APP_NAME}..."
swift build -c release -Xcc -O3 -Xcc -ffast-math -Xcc -flto -Xcc -DNDEBUG -Xswiftc -O
BINARY_PATH=$(swift build -c release --show-bin-path)/${APP_NAME}

# 2. Create Structure
echo "Creating App Bundle structure..."
rm -rf "${DIST_DIR}"
mkdir -p "${MACOS_DIR}"
mkdir -p "${RESOURCES_DIR}"

# 3. Copy Binary
cp "${BINARY_PATH}" "${MACOS_DIR}/"

# 4. Copy Resources
echo "Copying internal resources..."
if [ -f "resources/mec_logo.icns" ]; then
    cp "resources/mec_logo.icns" "${RESOURCES_DIR}/"
fi

# 5. Create Info.plist
echo "Generating Info.plist..."
cat > "${CONTENTS_DIR}/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDocumentTypes</key>
	<array>
		<dict>
			<key>CFBundleTypeName</key>
			<string>Media Editor Community</string>
			<key>CFBundleTypeRole</key>
			<string>Editor</string>
			<key>LSHandlerRank</key>
			<string>Owner</string>
			<key>LSIsAppleDefaultForType</key>
			<true/>
			<key>LSItemContentTypes</key>
			<array>
				<string>com.Code-Win.mec</string>
			</array>
		</dict>
	</array>
	<key>CFBundleExecutable</key>
	<string>${APP_NAME}</string>
	<key>CFBundleGetInfoString</key>
	<string>Media Editor Community</string>
	<key>CFBundleIconFile</key>
	<string>AppIcon</string>
	<key>CFBundleIconName</key>
	<string>AppIcon</string>
	<key>CFBundleIdentifier</key>
	<string>${IDENTIFIER}</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleLongVersionString</key>
	<string>0.9.9</string>
	<key>CFBundleName</key>
	<string>${APP_NAME}</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>0.9</string>
	<key>CFBundleVersion</key>
	<string>0.9.9.0</string>
	<key>CSResourcesFileMapped</key>
	<true/>
	<key>LSAppNapIsDisabled</key>
	<true/>
	<key>LSApplicationCategoryType</key>
	<string>public.app-category.video</string>
	<key>LSMinimumSystemVersion</key>
	<string>11.0</string>
	<key>NSAppTransportSecurity</key>
	<dict>
		<key>NSAllowsArbitraryLoads</key>
		<true/>
	</dict>
	<key>NSHighResolutionCapable</key>
	<true/>
	<key>NSHumanReadableCopyright</key>
	<string>Copyright © 2023-2026 CodeWin Team. All rights reserved.</string>
	<key>NSPrincipalClass</key>
	<string>NSApplication</string>
</dict>
</plist>
EOF

# 5a. Handle Assets
echo "Compiling Assets..."
XCASSETS_DIR="${DIST_DIR}/Assets.xcassets"
APPICON_SET="${XCASSETS_DIR}/AppIcon.appiconset"
rm -rf "${XCASSETS_DIR}"
mkdir -p "${APPICON_SET}"

SRC_IMAGE="resources/mec_logo.png"
if [ -f "${SRC_IMAGE}" ]; then
    echo "Generating icons from ${SRC_IMAGE}..."
    cp "${SRC_IMAGE}" "${APPICON_SET}/icon_512x512@2x.png"
    sips -z 1024 1024 "${SRC_IMAGE}" --out "${APPICON_SET}/icon_512x512@2x.png" > /dev/null
    sips -z 512 512   "${SRC_IMAGE}" --out "${APPICON_SET}/icon_512x512.png" > /dev/null
    sips -z 256 256   "${SRC_IMAGE}" --out "${APPICON_SET}/icon_256x256@2x.png" > /dev/null
    sips -z 256 256   "${SRC_IMAGE}" --out "${APPICON_SET}/icon_256x256.png" > /dev/null
    sips -z 128 128   "${SRC_IMAGE}" --out "${APPICON_SET}/icon_128x128.png" > /dev/null
    sips -z 64 64     "${SRC_IMAGE}" --out "${APPICON_SET}/icon_32x32@2x.png" > /dev/null
    sips -z 32 32     "${SRC_IMAGE}" --out "${APPICON_SET}/icon_32x32.png" > /dev/null
    sips -z 32 32     "${SRC_IMAGE}" --out "${APPICON_SET}/icon_16x16@2x.png" > /dev/null
    sips -z 16 16     "${SRC_IMAGE}" --out "${APPICON_SET}/icon_16x16.png" > /dev/null

    cat > "${APPICON_SET}/Contents.json" <<EOF
{
  "images" : [
    { "size" : "16x16", "idiom" : "mac", "filename" : "icon_16x16.png", "scale" : "1x" },
    { "size" : "16x16", "idiom" : "mac", "filename" : "icon_16x16@2x.png", "scale" : "2x" },
    { "size" : "32x32", "idiom" : "mac", "filename" : "icon_32x32.png", "scale" : "1x" },
    { "size" : "32x32", "idiom" : "mac", "filename" : "icon_32x32@2x.png", "scale" : "2x" },
    { "size" : "128x128", "idiom" : "mac", "filename" : "icon_128x128.png", "scale" : "1x" },
    { "size" : "128x128", "idiom" : "mac", "filename" : "icon_256x256.png", "scale" : "2x" },
    { "size" : "256x256", "idiom" : "mac", "filename" : "icon_256x256.png", "scale" : "1x" },
    { "size" : "256x256", "idiom" : "mac", "filename" : "icon_256x256@2x.png", "scale" : "2x" },
    { "size" : "512x512", "idiom" : "mac", "filename" : "icon_512x512.png", "scale" : "1x" },
    { "size" : "512x512", "idiom" : "mac", "filename" : "icon_512x512@2x.png", "scale" : "2x" }
  ],
  "info" : { "version" : 1, "author" : "xcode" }
}
EOF

    # actool compilation to create Assets.car
    echo "Running actool..."
    actool "${XCASSETS_DIR}" \
      --compile "${RESOURCES_DIR}" \
      --platform macosx \
      --minimum-deployment-target 11.0 \
      --output-partial-info-plist "${DIST_DIR}/partial.plist" \
      --app-icon AppIcon
else
    echo "Warning: resources/mec_logo.png not found. Skipping AppIcon compilation."
fi

# 6. Codesign
echo "Finding codesigning identity..."
IDENTITY=$(security find-identity -v -p codesigning | grep "Apple Development" | head -n 1 | awk '{print $2}' || true)

if [ -z "${IDENTITY}" ]; then
    echo "No valid Apple Development codesigning identity found. Using ad-hoc signature (-)..."
    IDENTITY="-"
fi

echo "Codesigning with identity: ${IDENTITY}"
echo "Codesigning App Bundle..."
codesign --force --deep --options runtime --entitlements resources/entitlements.plist --sign "${IDENTITY}" "${APP_BUNDLE}"

# Verify code signature
echo "Verifying code signature..."
codesign -vvv "${APP_BUNDLE}"

echo "Success! App bundle created at ${APP_BUNDLE}"
