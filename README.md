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



建议使用repo进行项目的管理

背景

我开发一个需求，有 RN 的改动，有原生的改动，我需要在两个仓库各拉一个分支。改动、提交、发布、合并、这些操作我都要执行两次。

如果使用repo的话，就直接给两个仓库拉一个分支，统一提交commit信息。方便回溯。统一推送到远端。

如果使用repo的话，我想拉取rn和原生的代码仓库还有其他第三方的仓库到最新的代码，我10个仓库就要执行10次git pull 如果某个仓库有代码未提交我还需要先stash，再进行pull。使用repo的话，直接一把把所有仓库都可以拉取到最新的。



### 建议使用 `repo` 工具统一管理多仓库项目

**痛点：传统 Git 管理的低效**

当项目涉及多个独立仓库（例如同时修改 React Native 和原生平台代码），传统的 Git 工作流会变得非常繁琐：

1. **分支操作重复：** 需要在 *每个* 相关仓库单独创建、切换、管理功能分支。
2. **提交与发布冗余：** 相同的功能改动或修复，需要在多个仓库分别执行 `git add`, `git commit`, `git push`，甚至重复构建发布流程。
3. **回溯困难：** 关联的改动分散在不同仓库的不同分支和提交记录中，追踪完整变更历史费时费力。
4. **同步成本高：** 更新所有依赖仓库到最新状态需要依次进入每个目录执行 `git pull`。如果某个仓库存在本地未提交修改，还需先 `git stash` 再拉取，拉取完可能还需 `git stash pop`，操作链条长且易出错，仓库数量越多越痛苦。

**解决方案：`repo` 带来的高效管理**

1. **统一分支管理：** 一条 `repo start <branch-name> --all` 命令即可在 *所有* 指定仓库创建同名分支。
2. **原子化提交：** `repo upload` 或 `repo forall -c 'git commit ...'` 等方式可以确保所有仓库的关联改动以**统一的提交信息**一起提交和推送。这极大地**简化了提交操作**，并保证了**提交历史的清晰性和可回溯性**。
3. **一键同步：** `repo sync` 命令是真正的“利器”。它能**一键拉取所有纳入管理的仓库**到最新状态。`repo` 会自动处理仓库间的依赖关系，并智能地处理类似本地未提交修改的情况（通常会提示或提供解决方案），**彻底告别逐个仓库 `git pull` 和 `git stash` 的繁琐操作**，即使管理数十个仓库也能轻松应对。
4. **一键递归拉取所有纳入管理的仓库（包括任何深度的嵌套子仓库！）** 到 manifest 定义的最新正确状态。
5. 解决了仓库嵌套仓库时，代码文件跟踪不到的一些问题