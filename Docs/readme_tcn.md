# FFmpeg 腳本工具集（Windows 批次檔版）

**（由 AI 生成，可能會有錯誤）**

[English](readme_en.md) | [中文](../README.md) | [繁體中文](readme_tcn.md)

### 這是一個 FFmpeg 批次處理工具集

---

## ✨ 功能特性總覽

### 1️⃣ `main.bat` —— 主選單

* 提供統一且簡潔的選單入口
* 呼叫各個子腳本
* 無多餘業務邏輯

### 2️⃣ `encode.bat` —— 視訊轉碼／壓縮模組

* 支援：H.264 / HEVC (H.265) / AV1
* **解碼方式**：CPU、NVIDIA CUVID、Intel QSV、AMD AMF
* **編碼方式**：CPU、NVENC、QSV、AMF
* 可選 **profile（main / high / high10 / main10）**
* 解析度可自訂（scale）
* 完整碼率控制（b:v / maxrate / bufsize）
* 音訊支援：複製、忽略、自訂編碼
* 字幕支援：複製、跳過、自訂
* 自動批次處理 `input` 資料夾

### 3️⃣ `mp4_to_gif.bat` —— MP4 批量轉 GIF

* 可自訂解析度
* 可調整幀率（建議 10–15）
* 批次處理 `input` 目錄
* 輸出為 GIF 檔案至 `output` 目錄

### 4️⃣ `extract_separate.bat` —— 視訊／音訊分離模組

* **提取純視訊流**（不含音訊，零損耗複製）
* **自動偵測所有音軌**
* **新增**：自動匹配正確副檔名（m4a / mp3 / ogg / flac / dts 等）
* 多音軌逐一提取並命名為：

  ```
  檔名-audio1.m4a
  檔名-audio2.ac3
  ...
  ```
* 視訊檔案輸出為：

  ```
  檔名-video-only.mp4
  ```

---

## 作者使用的 FFmpeg 版本（推薦）

下載連結：

👉 **Windows FFmpeg Release Full（latest release version: 8.1 2026-03-16）**
[https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-full.7z](https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-full.7z)

下載後解壓縮，將 `bin/` 加入系統 PATH 即可。

---

## 📘 使用方法

### 1. 將檔案放入 `input/`

支援任意格式（mp4 / mkv / mov / flac / mp3 / m4a……）

`.gitkeep` 檔案會自動忽略。

---

### 2. 執行 `main.bat`

選擇功能：

| 選項 | 功能腳本                               |
| -- | ---------------------------------- |
| 1  | 批次視訊轉碼／壓縮（encode.bat）              |
| 2  | MP4 批次轉 GIF（mp4_to_gif.bat）        |
| 3  | 分離視訊 + 多音軌提取（extract_separate.bat） |

---

### 3. 依提示設定參數

（解析度、幀率、profile、編碼器、碼率……）

---

### 4. 開始處理

輸出至：

* `output/`
* `audio-out/`（僅音訊提取腳本使用）

---

## ⚠️ 注意事項

1. **硬體加速需要顯示卡驅動支援**
2. CPU 軟編碼相容性最佳，但速度較慢
3. GIF 檔案體積通常較大，請謹慎選擇解析度與幀率
4. 若需檢測來源檔案資訊，建議使用 MediaInfo
