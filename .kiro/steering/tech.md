# Technology Stack

## Build System & Tools
- **Xcode**: Primary IDE and build system
- **CocoaPods**: Dependency management for iOS libraries
- **xcodebuild**: Command-line build tool for creating archives and XCFrameworks
- **Bash**: Shell scripting for automation (`build_xcframework.sh`)

## Platforms & Deployment
- **iOS 15.0+**: Minimum deployment target
- **Architectures**: iOS device and iOS Simulator support
- **Swift**: Primary language for the wrapper app
- **Objective-C**: Used by integrated libraries (YYCache)

## Key Dependencies
- **YYCache**: High-performance iOS caching framework (local pod)
- **SQLite3**: Database framework (required by YYCache)
- **UIKit, CoreFoundation, QuartzCore**: iOS system frameworks

## Common Commands

### Setup
```bash
# Install dependencies
pod install

# Open workspace (always use workspace, not project)
open XCFrameworkPackager.xcworkspace
```

### Building XCFrameworks
```bash
# Build XCFramework from Git repository
./build_xcframework.sh <git_repo_url> <scheme_name> [static|dynamic]

# Example with YYCache
./build_xcframework.sh https://github.com/ibireme/YYCache.git YYCache static
```

### Build Configuration
- **Configuration**: Release (default)
- **Library Types**: Static (default) or Dynamic
- **Build Settings**: 
  - `BUILD_LIBRARIES_FOR_DISTRIBUTION=YES`
  - `SKIP_INSTALL=NO`
  - Swift module interface preservation enabled