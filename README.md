# FFmpeg 脚本工具集（Windows 批处理版）

[English](./Docs/readme_en.md) | [中文](README.md) | [繁体中文](./Docs/readme_tcn.md)

### 这是一个 FFmpeg 批处理工具集。

---

## ✨ 功能特性总览

### 1️⃣ `main.bat` —— 主菜单
* 提供统一简洁的菜单入口
* 调用各个子脚本
* 无多余业务逻辑

### 2️⃣ `encode.bat` —— 视频转码/压缩模块
* 支持：H.264 / HEVC(H.265) / AV1
* **解码方式**：CPU、NVIDIA CUVID、Intel QSV、AMD AMF
* **编码方式**：CPU、NVENC、QSV、AMF
* 可选 **profile（main/high/high10/main10）**
* 分辨率可自定义（scale）
* 完整码率控制（b:v / maxrate / bufsize）
* 音频支持：复制、忽略、自定义编码
* 字幕支持：复制、跳过、自定义
* 自动批处理 input 文件夹

### 3️⃣ `mp4_to_gif.bat` —— MP4 批量转 GIF
* 可自定义分辨率
* 可调帧率（10–15 推荐）
* 批量处理 input 目录
* 输出为 GIF 文件到 output 目录

### 4️⃣ `extract_separate.bat` —— 视频/音频分离模块
* **提取纯视频流**（不含音频，零损耗复制）
* **自动检测所有音轨**
* **新增**：自动匹配正确扩展名（m4a/mp3/ogg/flac/dts 等）
* 多音轨逐个提取并命名为：
  ```
  文件名-audio1.m4a
  文件名-audio2.ac3
  ...
  ```
* 视频文件输出为：
  ```
  文件名-video-only.mp4
  ```

---

## 作者使用的 FFmpeg 版本（推荐）

下载链接：

👉 **Windows FFmpeg Release Full（latest release version: 8.1 2026-03-16）**
[https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-full.7z](https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-full.7z)

下载后解压，将 `bin/` 加入系统 PATH 即可。

---

## 📘 使用方法

### 1. 将文件放入 `input/`

支持任意格式（mp4/mkv/mov/flac/mp3/m4a……）

`.gitkeep` 文件会自动忽略。

---

### 2. 运行 `main.bat`

选择功能：

| 选项 | 功能脚本                               |
| -- | ---------------------------------- |
| 1  | 批量视频转码/压缩（encode.bat）                 |
| 2  | MP4 批量转 GIF（mp4_to_gif.bat）        |
| 3  | 分离视频 + 多音轨提取（extract_separate.bat） |

---

### 3. 按提示设置参数

（分辨率、帧率、profile、编码器、码率……）

---

### 4. 开始处理

输出到：

* `output/`
* `audio-out/`（仅音频提取脚本使用）

---

## ⚠️ 注意事项

1. **硬件加速需要显卡驱动支持**
2. CPU 软编码兼容性最佳但速度较慢
3. GIF 文件体积通常较大，选择分辨率与帧率要谨慎
4. 若需要检测源文件信息，推荐使用 MediaInfo
