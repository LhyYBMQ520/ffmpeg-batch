# FFmpeg 脚本工具集（Windows 批处理版）

这是一个基于 FFmpeg 的 Windows 批处理工具集，提供视频转码、MP4 转 GIF、视频音频分离三项功能。

## 功能总览

### 1. 视频转码/压缩

脚本：`batch-files/encode.bat`

- 使用 FFprobe 自动检测源视频编码，不再手动选择 H.264、HEVC 或 AV1 输入格式。
- 支持 CPU、NVIDIA CUVID、Intel QSV、AMD AMF 解码。
- 支持 CPU、NVIDIA NVENC、Intel QSV、AMD AMF 编码。
- 支持目标编码 H.264、HEVC/H.265、AV1。
- AV1 自动使用 Main 配置并跳过 `profile` 参数。
- 可选分辨率转换。
- 支持目标码率、最高码率和自动计算的缓冲区大小（最高码率的 2 倍）。
- 支持音频复制、忽略或自定义编码参数。
- 支持字幕复制、跳过或自定义编码参数。
- 处理前检测源视频编码，检测成功后等待 2 秒，便于确认输入信息。
- 没有视频流或视频编码检测失败的文件会跳过转码。

#### 目标容器

转码时可以选择目标容器，输出扩展名和 FFmpeg muxer 会根据选择确定，不再沿用输入文件扩展名。

| 容器 | 扩展名 | 说明 |
| --- | --- | --- |
| MKV | `.mkv` | 默认选项，兼容性最好，支持多音轨、ASS 字幕和字体附件 |
| MP4 | `.mp4` | ASS 字幕自动转换为 `mov_text`，不复制字体附件；音频保持 `-c:a copy` |
| WebM | `.webm` | 仅允许 AV1 目标编码；音频自动转换为 Opus，字幕自动转换为 WebVTT，不复制字体附件 |

脚本会显式指定 `-f matroska`、`-f mp4` 或 `-f webm`，避免仅依赖文件扩展名选择 muxer。

### 2. MP4 转 GIF

脚本：`batch-files/mp4_to_gif.bat`

- 支持自定义 GIF 分辨率和帧率。
- 使用 `palettegen` + `paletteuse` 调色板流程，改善颜色数量、色带和抖动问题。
- 使用 Lanczos 缩放。
- 自动添加 `-an`，明确移除音频。
- 自动添加 `-loop 0`，生成无限循环 GIF。
- 批量处理 `input` 目录中的视频文件，输出到 `output` 目录。

### 3. 分离视频和音频流

脚本：`batch-files/extract_separate.bat`

- 视频输出为纯视频流，使用 `-c:v copy -an -sn -dn`，不包含音频、字幕或数据流。
- 自动检测所有音轨并逐条提取。
- 使用 `ffprobe -v error` 检测音频编码，检测失败时跳过音频提取，不会把错误文本当作 codec 名称。
- 音频文件输出到 `audio-out`，文件名格式为：

  ```text
  文件名-audio1.m4a
  文件名-audio2.ac3
  ```

- 根据 codec 映射扩展名和 muxer，常见映射包括：
  - `aac`、`alac` -> `.m4a`
  - `mp3` -> `.mp3`
  - `opus` -> `.opus`
  - `vorbis`、`speex` -> `.ogg`
  - `flac` -> `.flac`
  - `ac3`、`eac3`、`dts` -> 对应原始扩展名
  - `truehd` -> `.thd`
  - `mlp` -> `.mlp`
  - `amr_nb` -> `.amr`
  - `g722`、`adpcm_g722` -> `.g722`
  - 小端 PCM -> `.wav`
  - 大端 PCM -> `.aiff`
  - 其他未知或不适合独立容器的音频 -> `.mka`

`.gitkeep` 文件会自动跳过。输入目录中包含纯音频文件时，分离脚本会报告视频提取失败，但仍会继续提取音频。

## 使用方法

1. 将待处理的视频放入 `input` 目录。
2. 双击运行 `main.bat`。
3. 选择功能并按提示设置参数。
4. 视频和 GIF 输出到 `output`，分离出的音频输出到 `audio-out`。

## 环境要求

- Windows。
- FFmpeg 和 FFprobe 已安装并加入系统 `PATH`。
- 使用 NVIDIA、Intel 或 AMD 硬件加速时，需要对应的驱动和 FFmpeg 编解码器支持。
- 可使用 MediaInfo 或 FFprobe 查看源文件的详细流信息。

推荐使用包含完整编码器和硬件支持的 FFmpeg Release Full Build。

## 注意事项

- MKV 是默认且兼容性最好的目标容器。
- MP4 音频使用复制模式时，源音频必须是 MP4 兼容格式；不兼容的音频需要在“自定义音频参数”中重新编码为 AAC 等格式。
- WebM 只允许 AV1 视频目标编码，并会自动使用 Opus 音频和 WebVTT 字幕。
- GIF 体积通常较大，降低分辨率和帧率可以明显减小文件大小。
- 已存在的输出文件可能会触发 FFmpeg 覆盖确认。
