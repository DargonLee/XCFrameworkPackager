# XCFrameworkPackager

一个用于将第三方 iOS 库打包为 XCFramework 的自动化工具。

## 项目简介

XCFrameworkPackager 是一个专门用于将第三方 iOS 库（如 CocoaPods 依赖）自动打包成 XCFramework 格式的工具。通过这个工具，你可以轻松地将任何支持的 iOS 库转换为可分发的 XCFramework 包。

## 主要功能

- 🚀 **自动化构建**：从 Git 仓库自动克隆并构建 XCFramework
- 📱 **多架构支持**：同时支持 iOS 设备和模拟器架构
- ⚙️ **灵活配置**：支持静态库和动态库两种打包方式
- 🔧 **CocoaPods 集成**：无缝集成 CocoaPods 依赖管理
- 📦 **标准化输出**：生成标准的 XCFramework 格式

## 系统要求

- macOS 系统
- Xcode 14.0+
- iOS 15.0+ 部署目标
- CocoaPods

## 快速开始

### 1. 环境准备

```bash
# 安装依赖
pod install

# 打开工作空间（重要：必须使用 .xcworkspace 文件）
open XCFrameworkPackager.xcworkspace
```

### 2. 构建 XCFramework

使用构建脚本将第三方库打包为 XCFramework：

```bash
# 基本用法
./build_xcframework.sh <Git仓库地址> <Scheme名称> [static|dynamic]

# 示例：构建 YYCache 静态库
./build_xcframework.sh https://github.com/ibireme/YYCache.git YYCache static

# 示例：构建动态库
./build_xcframework.sh https://github.com/ibireme/YYCache.git YYCache dynamic
```

### 3. 获取构建结果

构建完成后，XCFramework 文件将输出到 `build/` 目录：

```
build/
└── YYCache.xcframework/
    ├── ios-arm64/
    └── ios-arm64_x86_64-simulator/
```

## 工作原理

1. **自动克隆**：脚本会自动从指定的 Git 仓库克隆源码到 `LocalPods/` 目录
2. **Podfile 更新**：自动将新的 pod 依赖添加到 Podfile 中
3. **依赖安装**：运行 `pod install` 安装依赖
4. **多架构构建**：分别为 iOS 设备和模拟器构建 archive
5. **XCFramework 创建**：使用 `xcodebuild -create-xcframework` 合并多架构
6. **清理临时文件**：自动清理中间构建产物

## 项目结构

```
XCFrameworkPackager/
├── XCFrameworkPackager.xcworkspace    # 主工作空间文件
├── build_xcframework.sh               # 构建脚本
├── Podfile                           # CocoaPods 配置
├── LocalPods/                        # 本地 Pod 源码
│   └── YYCache/                      # 示例：YYCache 库
├── build/                            # 构建输出目录
└── XCFrameworkPackager/              # 应用源码
    ├── AppDelegate.swift
    └── ViewController.swift
```

## 支持的库类型

- **静态库**（默认）：生成 `.a` 静态链接库
- **动态库**：生成 `.dylib` 动态链接库

## 构建配置

- **部署目标**：iOS 15.0+
- **构建配置**：Release
- **架构支持**：arm64（设备）+ x86_64/arm64（模拟器）
- **分发设置**：`BUILD_LIBRARIES_FOR_DISTRIBUTION=YES`

## 常见问题

### Q: 为什么要使用 .xcworkspace 而不是 .xcodeproj？
A: 因为项目使用了 CocoaPods，必须使用 workspace 文件才能正确加载所有依赖。

### Q: 如何添加新的第三方库？
A: 运行构建脚本时指定新的 Git 仓库地址即可，脚本会自动处理克隆和配置。

### Q: 构建失败怎么办？
A: 检查目标库是否支持 iOS 15.0+，以及是否有正确的 podspec 文件。

## 示例库

项目中包含了 YYCache 作为示例，这是一个高性能的 iOS 缓存框架：

- **功能**：内存和磁盘缓存
- **性能**：LRU 算法，线程安全
- **兼容性**：API 类似 NSCache

## GitHub Actions 自动化部署

项目支持使用 GitHub Actions 进行自动化构建和部署：

### 🚀 自动构建

每次推送到 `main` 或 `develop` 分支时，会自动触发构建：

- 自动构建 YYCache XCFramework
- 上传构建产物到 GitHub Artifacts
- 保留 30 天供下载

### 🎯 手动触发构建

在 GitHub 仓库的 Actions 页面，可以手动触发构建：

1. 进入 **Actions** 标签页
2. 选择 **Build XCFramework** 工作流
3. 点击 **Run workflow**
4. 输入参数：
   - Git 仓库地址
   - Scheme 名称
   - 库类型（static/dynamic）

### 📦 发布版本

创建 Release 时自动构建并上传 XCFramework：

```bash
# 创建标签并推送
git tag v1.0.0
git push origin v1.0.0

# 或在 GitHub 网页上创建 Release
```

### 工作流文件

- `.github/workflows/build-xcframework.yml` - 主构建工作流
- `.github/workflows/release.yml` - 发布工作流

### 构建环境

- **运行环境**：macOS Latest
- **Xcode**：Latest Stable
- **CocoaPods**：自动安装最新版本
- **缓存**：Pod 依赖缓存加速构建

## 贡献

欢迎提交 Issue 和 Pull Request 来改进这个工具。

## 许可证

MIT License