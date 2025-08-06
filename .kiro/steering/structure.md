# Project Structure

## Root Level
- `XCFrameworkPackager.xcworkspace` - Main workspace file (always use this, not .xcodeproj)
- `XCFrameworkPackager.xcodeproj/` - Xcode project configuration
- `Podfile` - CocoaPods dependency specification
- `Podfile.lock` - Locked dependency versions
- `build_xcframework.sh` - Main build automation script
- `build/` - Build output directory (generated)

## Application Code
```
XCFrameworkPackager/
├── AppDelegate.swift          # App lifecycle management
├── SceneDelegate.swift        # Scene-based app architecture
├── ViewController.swift       # Main view controller
├── Info.plist                # App configuration
├── Assets.xcassets/          # App icons and assets
└── Base.lproj/               # Storyboards and localization
    ├── Main.storyboard
    └── LaunchScreen.storyboard
```

## Dependencies
```
LocalPods/                    # Local pod sources
└── YYCache/                 # Example: YYCache library
    ├── YYCache/             # Source files (.h, .m)
    ├── Framework/           # Framework project
    ├── Benchmark/           # Performance tests
    └── YYCache.podspec      # Pod specification

Pods/                        # CocoaPods managed dependencies
├── Headers/                 # Public headers
├── Target Support Files/    # Build configurations
└── Pods.xcodeproj/         # Generated pods project
```

## Conventions

### File Organization
- Keep local pods in `LocalPods/` directory
- Use descriptive folder names matching the library name
- Maintain original library structure when possible

### Build Artifacts
- All build outputs go to `build/` directory
- XCFrameworks are named `<SchemeName>.xcframework`
- Intermediate archives are cleaned up automatically

### Configuration Files
- Always work with `.xcworkspace`, never `.xcodeproj` directly
- Pod specifications should be in the root of each local pod
- Build scripts should be executable and in the project root