#!/usr/bin/env bash
set -euo pipefail

# 参数：Git 源码链接 + scheme + [库类型(static|dynamic，默认 static)]
if [[ $# -lt 2 || $# -gt 3 ]]; then
echo "Usage: $0 <git_repo_url> <scheme_name> [static|dynamic]"
exit 1
fi
GIT_REPO="$1"
SCHEME="$2"
LIB_KIND="${3:-static}"  # 默认 static

if [[ "$LIB_KIND" != "static" && "$LIB_KIND" != "dynamic" ]]; then
echo "Third argument must be 'static' or 'dynamic' when provided. Got: $LIB_KIND"
exit 1
fi

WORKSPACE_NAME="XCFrameworkPackager.xcworkspace"
TARGET_NAME="XCFrameworkPackager"
CONFIGURATION="${CONFIGURATION:-Release}"
BUILD_DIR="${BUILD_DIR:-build}"
DERIVED_DATA_DIR="${DERIVED_DATA_DIR:-$BUILD_DIR/DerivedData}"
SWIFT_FLAGS="-Xfrontend -module-interface-preserve-types-as-written"
LOCAL_PODS_DIR_NAME="LocalPods"
log() { echo "[INFO] $*"; }
err() { echo "[ERROR] $*" >&2; }

REPO_DIR="$(basename "$GIT_REPO" .git)"

log "CONFIGURATION: $CONFIGURATION"
log "BUILD_DIR: $BUILD_DIR"
log "REPO_DIR: $REPO_DIR"


# 1) 清理输出
rm -rf "$BUILD_DIR"

# 2) 克隆仓库到脚本同级目录下的 LocalPods/<RepoName>
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

LOCAL_PODS_DIR="$SCRIPT_DIR/$LOCAL_PODS_DIR_NAME"
CLONE_DIR="$LOCAL_PODS_DIR/$REPO_DIR"
if [[ -d "$CLONE_DIR" ]]; then
log "Repo dir already exists: $CLONE_DIR, skip cloning."
else
log "Cloning $GIT_REPO into $CLONE_DIR"
git clone --depth 1 "$GIT_REPO" "$CLONE_DIR"
fi

# 3) 写入 Podfile：pod '<SCHEME>', :path => './<REPO_DIR>' 到末尾
PODFILE="$SCRIPT_DIR/Podfile"
POD_ENTRY="pod '$SCHEME', :path => './$LOCAL_PODS_DIR_NAME/$REPO_DIR'"


if [[ ! -f "$PODFILE" ]]; then
err "Podfile not found at $PODFILE"
exit 1
fi

# 已存在则跳过
if grep -Fq "$POD_ENTRY" "$PODFILE"; then
log "Podfile already contains: $POD_ENTRY"
else
# 只定位目标 target 块
if grep -Eq "^target[[:space:]]+['\"]${TARGET_NAME}['\"][[:space:]]+do" "$PODFILE"; then
# 在匹配 target 块的 end 之前插入（保持 target 尾部）
awk -v tgt="$TARGET_NAME" -v entry="  $POD_ENTRY" '
      BEGIN {
        in_target = 0
        target_re = "^target[[:space:]]+[\047\"]" tgt "[\047\"][[:space:]]+do[[:space:]]*$"
      }
      {
        if ($0 ~ target_re) {
          in_target = 1
        } else if (in_target && $0 ~ /^[[:space:]]*end[[:space:]]*$/) {
          print entry
          in_target = 0
        }
        print $0
      }
    ' "$PODFILE" > "$PODFILE.tmp" && mv "$PODFILE.tmp" "$PODFILE"
log "Injected into target '${TARGET_NAME}': $POD_ENTRY"
else
err "Target '${TARGET_NAME}' not found in Podfile. Please ensure it exists."
exit 1
fi
fi

# 4) pod install
log "Running pod install"
pod install

# 5) 构建函数（保持现有逻辑，修正 destination/sdk）
build_xcframework() {
    local scheme="$1"
    local lib_kind="$2"  # static | dynamic
    
    local macho_flag=""
    if [[ "$lib_kind" == "static" ]]; then
      macho_flag="staticlib"
    else
      macho_flag="mh_dylib"
    fi
    
    # iOS Device
    xcodebuild archive \
    -workspace "$WORKSPACE_NAME" \
    -scheme "$scheme" \
    -destination "generic/platform=iOS" \
    -configuration "$CONFIGURATION" only_active_arch=no \
    -sdk iphoneos \
    -archivePath "$BUILD_DIR/ios_devices.xcarchive" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARIES_FOR_DISTRIBUTION=YES \
    OTHER_SWIFT_FLAGS="$SWIFT_FLAGS" \
    MACH_O_TYPE="$macho_flag"
    
    # iOS Simulator
    xcodebuild archive \
    -workspace "$WORKSPACE_NAME" \
    -scheme "$scheme" \
    -destination "generic/platform=iOS Simulator" \
    -configuration "$CONFIGURATION" only_active_arch=no \
    -sdk iphonesimulator \
    -archivePath "$BUILD_DIR/ios_simulator.xcarchive" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARIES_FOR_DISTRIBUTION=YES \
    OTHER_SWIFT_FLAGS="$SWIFT_FLAGS" \
    MACH_O_TYPE="$macho_flag"
    
    # Create XCFramework
    xcodebuild -create-xcframework \
    -framework "$BUILD_DIR/ios_devices.xcarchive/Products/Library/Frameworks/$scheme.framework" \
    -framework "$BUILD_DIR/ios_simulator.xcarchive/Products/Library/Frameworks/$scheme.framework" \
    -output "$BUILD_DIR/$scheme.xcframework"
    
    # Cleanup intermediate archives
    rm -rf "$BUILD_DIR/ios_devices.xcarchive" "$BUILD_DIR/ios_simulator.xcarchive"
}

# 6) 构建指定 scheme
log "Building scheme: $SCHEME ($LIB_KIND)"
build_xcframework "$SCHEME" "$LIB_KIND"
log "Done building: $SCHEME.xcframework"
log "All done. Output at: $BUILD_DIR"
