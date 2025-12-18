# FFmpeg 脚本工具集（Windows 批处理版）

[English](./Docs/readme_en.md) | [中文](README.md) | [繁体中文](./Docs/readme_tcn.md)

这是一个强化后的 FFmpeg 批处理工具集，将原本合并在一起的大型脚本 **拆分为 4 个模块化脚本**，结构更清晰、维护更容易，也更便于单独更新每个功能。

新版框架由 **主菜单 main.bat 调起其他三个功能脚本**，并将所有逻辑功能独立存放在 `batch-files/` 文件夹中。

---

## 📌 2025.12.18重要更新

### ✔️ **新增两个实用功能脚本：**

| 脚本文件              | 功能                                                   |
| ------------------- | ---------------------------------------------------- |
| **mkv_to_mp4.bat**  | MKV 批量转 MP4（无损复制音视频流，自动处理字幕兼容性问题）         |
| **ogg_to_m4a.bat**  | OGG 批量转 M4A（AAC 编码，256kbps 高质量音频转换）            |

---

## 📌 2025.11.19重要更新

### ✔️ **原来的单一大脚本已拆分为四个独立的功能脚本：**

| 脚本文件                     | 功能                                           |
| ------------------------ | -------------------------------------------- |
| **main.bat**             | 主菜单入口，统一调度所有子脚本                              |
| **encode.bat**           | 批量视频转码（H.264 / HEVC / AV1，含硬件加速、分辨率、码率等完整配置） |
| **mp4_to_gif.bat**       | MP4 批量转 GIF（可选分辨率、帧率）                        |
| **extract_separate.bat** | 分离视频流（无音频） + 提取多音轨，并自动识别音频编码与扩展名             |

### ✔️ 优点

* **结构化、易维护**
* **每个功能独立，不会互相污染或冲突**
* **主菜单更简洁，用户更容易理解**
* **新增多音轨自动编码识别与扩展名匹配**
* **新增常用格式快速转换（MKV→MP4、OGG→M4A）**
* **所有脚本均批量处理 input/ 文件夹**

---

## 作者使用的 FFmpeg 版本（推荐）

下载链接：

👉 **Windows FFmpeg Release Full（8.0）**
[https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-full.7z](https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-full.7z)

下载后解压，将 `bin/` 加入系统 PATH 即可。

---

## ✨ 功能特性总览（按新结构整理）

### 1️⃣ `encode.bat` —— 视频转码模块

* 支持：H.264 / HEVC(H.265) / AV1
* **解码方式**：CPU、NVIDIA CUVID、Intel QSV、AMD AMF
* **编码方式**：CPU、NVENC、QSV、AMF
* 可选 **profile（main/high/high10/main10）**
* 分辨率可自定义（scale）
* 完整码率控制（b:v / maxrate / bufsize）
* 音频支持：复制、忽略、自定义编码
* 字幕支持：复制、跳过、自定义
* 自动批处理 input 文件夹

---

### 2️⃣ `mp4_to_gif.bat` —— MP4 批量转 GIF

* 可自定义分辨率（建议小尺寸）
* 可调帧率（10–15 推荐）
* 批量处理 input 目录
* 输出为 GIF 文件到 output 目录

---

### 3️⃣ `extract_separate.bat` —— 视频/音频分离模块（本次大幅强化）

* **提取纯视频流**（不含音频，零损耗复制）
* **自动检测所有音轨**
* 自动匹配正确扩展名（m4a/mp3/ogg/flac/dts 等）
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

### 4️⃣ `mkv_to_mp4.bat` —— MKV 批量转 MP4（新增）

* **无损复制音视频流**（不重新编码，速度极快）
* 自动处理字幕兼容性问题（mov_text 格式）
* 多级容错机制：
  * 首选：完整复制（含字幕转换）
  * 备选：跳过字幕转换
  * 最终：仅复制音视频流
* 自动添加 `faststart` 优化网络播放
* 批量处理 input 目录，输出到 output 目录

---

### 5️⃣ `ogg_to_m4a.bat` —— OGG 批量转 M4A（新增）

* OGG (Vorbis) 转换为 M4A (AAC) 格式
* 使用 AAC 编码，**256kbps 高质量**输出
* 兼容 iOS / macOS / iTunes 等苹果生态
* 批量处理 input 目录，输出到 output 目录

---

### 6️⃣ `main.bat` —— 主菜单控制中心（全新重构）

* 提供统一菜单入口
* 调用 encode / mp4_to_gif / extract_separate 各子脚本
* 保持界面清晰、无多余逻辑

---

## 📁 目录结构

```
项目目录/
│
├── main.bat                  # 主菜单脚本
│
├── batch-files/              # 5 个独立功能脚本
│   ├── encode.bat            # 视频转码
│   ├── mp4_to_gif.bat        # MP4 转 GIF
│   ├── extract_separate.bat  # 视频/音频分离提取
│   ├── mkv_to_mp4.bat        # MKV 转 MP4
│   └── ogg_to_m4a.bat        # OGG 转 M4A
│
├── input/                    # 输入文件夹
│   └── .gitkeep
│
├── output/                   # 视频输出（转码/GIF/视频-only）
│
└── audio-out/                # 音频提取输出（由 extract_separate.bat 创建）
```

---

## 📘 使用方法（新版简化版）

### 1. 将文件放入 `input/`

支持任意格式（mp4/mkv/mov/flac/mp3/m4a……）
`.gitkeep` 自动忽略。

---

### 2. 运行 `main.bat`

选择功能：

| 选项 | 功能脚本                               |
| -- | ---------------------------------- |
| 1  | 批量视频转码（encode.bat）                 |
| 2  | MP4 批量转 GIF（mp4_to_gif.bat）        |
| 3  | 分离视频 + 多音轨提取（extract_separate.bat） |
| 4  | OGG 批量转 M4A（ogg_to_m4a.bat）        |
| 5  | MKV 批量转 MP4（mkv_to_mp4.bat）        |

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

---
