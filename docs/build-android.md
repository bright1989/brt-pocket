# Android 本地构建指南

## 快速开始

### 1. 构建 Debug 版本（测试用）

```bash
# 方式 1: 使用 npm 脚本（推荐）
npm run build:android

# 方式 2: 直接运行脚本
node scripts/build-android.cjs
```

这将生成一个 debug APK，可以直接安装到测试设备上。

### 2. 构建 Release 版本

```bash
# 构建签名或未签名的 release APK
npm run build:android:release

# 或直接运行
node scripts/build-android.cjs --release
```

### 3. 构建 Google Play Bundle (AAB)

```bash
# 构建用于上传到 Google Play 的 AAB 文件
npm run build:android:bundle

# 或直接运行
node scripts/build-android.cjs --bundle
```

### 4. Clean Build

```bash
# 清理并重新构建
npm run build:android:clean

# 或组合使用
node scripts/build-android.cjs --clean --release
```

## 输出文件位置

- **Debug APK**: `apps/mobile/build/app/outputs/flutter-apk/app-debug.apk`
- **Release APK**: `apps/mobile/build/app/outputs/flutter-apk/app-release.apk`
- **Release AAB**: `apps/mobile/build/app/outputs/bundle/release/app-release.aab`

## 安装到设备

### 通过 ADB 安装

```bash
# 安装 debug 版本
adb install apps/mobile/build/app/outputs/flutter-apk/app-debug.apk

# 安装 release 版本
adb install apps/mobile/build/app/outputs/flutter-apk/app-release.apk
```

### 直接传输 APK 文件

将生成的 APK 文件传输到 Android 设备，然后在设备上打开并安装。

## 配置签名（可选）

如果要构建正式发布的签名版本，需要配置 keystore：

1. 复制示例配置文件：
   ```bash
   cp apps/android/keystore.properties.example apps/android/keystore.properties
   ```

2. 编辑 `apps/android/keystore.properties`：
   ```properties
   storePassword=你的密钥库密码
   keyAlias=你的密钥别名
   keyPassword=密钥密码
   storeFile=../keystore.jks
   ```

3. 将你的 keystore 文件（.jks）放在 `apps/android/` 目录下

## 故障排除

### Flutter 未找到

确保 Flutter 已正确安装并添加到 PATH：
```bash
flutter doctor
```

### Android SDK 未找到

确保 Android SDK 已安装并配置环境变量：
- Windows: 设置 `ANDROID_HOME` 和将 `%ANDROID_HOME%\platform-tools` 添加到 PATH
- macOS/Linux: 在 `.bashrc` 或 `.zshrc` 中添加 `export ANDROID_HOME=/path/to/sdk`

### 构建失败

尝试 clean build：
```bash
npm run build:android:clean
```

### Gradle 构建缓慢

首次构建会下载所有依赖，可能需要几分钟。后续构建会快很多。

## 高级选项

脚本支持更多参数：

```bash
node scripts/build-android.cjs --help
```

其他选项：
- `--release`: 构建 release 版本
- `--bundle`: 构建 AAB 而不是 APK
- `--clean`: 执行 clean build
- `--help`: 显示帮助信息

## CI/CD 集成

可以在 GitHub Actions 或其他 CI 工具中使用：

```yaml
- name: Build Android APK
  run: npm run build:android:release
```
