# FFmpeg 腳本工具集（Windows 批次檔版）

**（由 ChatGPT 生成，可能會有錯誤）**

[English](readme_en.md) | [中文](../README.md) | [繁體中文](readme_tcn.md)

這是一組強化後的 FFmpeg 批次處理工具集，將原本合併在一起的大型腳本 **拆分成 4 個模組化腳本**，結構更清晰、維護更容易，也更方便單獨更新每個功能。

新版架構由 **主選單 main.bat 呼叫五個功能腳本**，所有功能腳本均放在 `batch-files/` 資料夾中。

---

## 📌 2025.12.18重要更新

### ✔️ **新增兩個實用功能腳本：**

| 腳本檔案              | 功能                                                   |
| ------------------- | ---------------------------------------------------- |
| **mkv_to_mp4.bat**  | MKV 批次轉 MP4（無損複製音視訊流，自動處理字幕相容性問題）         |
| **ogg_to_m4a.bat**  | OGG 批次轉 M4A（AAC 編碼，256kbps 高品質音訊轉換）            |

---

## 📌 2025.11.19重要更新

### ✔️ **原本的單一大型腳本已拆分為六個獨立功能腳本：**

| 腳本檔案                     | 功能                                         |
| ------------------------ | ------------------------------------------ |
| **main.bat**             | 主選單入口，負責調用所有子腳本                            |
| **encode.bat**           | 批次影片轉碼（H.264 / HEVC / AV1，含硬體加速、解析度、碼率等設定） |
| **mp4_to_gif.bat**       | MP4 批次轉 GIF（可自訂解析度、幀率）                     |
| **extract_separate.bat** | 分離影片流（無音訊）＋提取多音軌，自動判斷音訊編碼並給予正確的副檔名         |
| **mkv_to_mp4.bat**       | MKV 批次轉 MP4（無損複製，自動處理字幕）                      |
| **ogg_to_m4a.bat**       | OGG 批次轉 M4A（AAC 高品質轉換）                        |

### ✔️ 特色

* **架構清楚、易於維護**
* **每個功能皆獨立，不會互相干擾**
* **主選單更簡潔易懂**
* **新增多音軌自動辨識與擴展名匹配**
* **新增常用格式快速轉換（MKV→MP4、OGG→M4A）**
* **所有腳本均批次處理 input/ 資料夾**

---

## 作者使用的 FFmpeg 版本（建議）

下載來源：

👉 **Windows FFmpeg Release Full（8.0）**
[https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-full.7z](https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-full.7z)

下載後解壓，將 `bin/` 加入系統 PATH 即可。

---

## ✨ 功能總覽（按新模組結構整理）

### 1️⃣ `encode.bat` —— 影片轉碼模組

* 支援：H.264 / HEVC(H.265) / AV1
* **解碼方式**：CPU、NVIDIA CUVID、Intel QSV、AMD AMF
* **編碼方式**：CPU、NVENC、QSV、AMF
* 可選擇 **profile（main / high / high10 / main10）**
* 可自訂縮放解析度（scale）
* 完整碼率控制（b:v / maxrate / bufsize）
* 音訊：複製、忽略、自訂編碼
* 字幕：複製、移除、自訂
* 自動批次讀取 input 資料夾

---

### 2️⃣ `mp4_to_gif.bat` —— MP4 批次轉 GIF

* 可自訂解析度（建議縮小以避免檔案過大）
* 可調整幀率（建議 10–15）
* 支援批次處理 input 目錄
* 輸出 GIF 至 output 目錄

---

### 3️⃣ `extract_separate.bat` —— 影片 / 音軌分離（本次加強最多）

* **提取純影片流**（不含音訊，無損 copy）
* **自動偵測所有音軌**
* 自動匹配正確副檔名（m4a / mp3 / ogg / flac / dts ...）
* 多音軌依序輸出成：

```
檔名-audio1.m4a
檔名-audio2.ac3
...
```

* 影片輸出為：

```
檔名-video-only.mp4
```

---

### 4️⃣ `mkv_to_mp4.bat` —— MKV 批次轉 MP4（新增）

* **無損複製音視訊流**（不重新編碼，速度極快）
* 自動處理字幕相容性問題（mov_text 格式）
* 多級容錯機制：
  * 首選：完整複製（含字幕轉換）
  * 備選：跳過字幕轉換
  * 最終：僅複製音視訊流
* 自動添加 `faststart` 優化網路播放
* 批次處理 input 目錄，輸出到 output 目錄

---

### 5️⃣ `ogg_to_m4a.bat` —— OGG 批次轉 M4A（新增）

* OGG (Vorbis) 轉換為 M4A (AAC) 格式
* 使用 AAC 編碼，**256kbps 高品質**輸出
* 相容 iOS / macOS / iTunes 等蘋果生態
* 批次處理 input 目錄，輸出到 output 目錄

---

### 6️⃣ `main.bat` —— 主選單控制中心（重新設計）

* 提供統一入口
* 呼叫 encode / mp4_to_gif / extract_separate 三個子腳本
* 界面更清晰、易於擴充

---

## 📁 目錄結構

```
專案目錄/
│
├── main.bat                  # 主選單
│
├── batch-files/              # 5 個功能腳本
│   ├── encode.bat            # 影片轉碼
│   ├── mp4_to_gif.bat        # MP4 轉 GIF
│   ├── extract_separate.bat  # 影片/音軌提取
│   ├── mkv_to_mp4.bat        # MKV 轉 MP4
│   └── ogg_to_m4a.bat        # OGG 轉 M4A
│
├── input/                    # 輸入資料夾
│   └── .gitkeep
│
├── output/                   # 影片輸出（轉碼/GIF/Video-only）
│
└── audio-out/                # 多音軌輸出資料夾（由 extract_separate.bat 自動建立）
```

---

## 📘 使用方式（簡明版）

### 1. 將影片/音訊檔放入 `input/`

支援多種格式（mp4 / mkv / mov / flac / mp3 / m4a …）
`.gitkeep` 會被自動略過。

---

### 2. 執行 `main.bat`

選擇功能：

| 選項 | 對應腳本                               |
| -- | ---------------------------------- |
| 1  | 批次影片轉碼（encode.bat）                 |
| 2  | MP4 批次轉 GIF（mp4_to_gif.bat）        |
| 3  | 影片分離 + 多音軌提取（extract_separate.bat） |
| 4  | OGG 批次轉 M4A（ogg_to_m4a.bat）        |
| 5  | MKV 批次轉 MP4（mkv_to_mp4.bat）        |

---

### 3. 根據提示設定參數

如解析度、碼率、profile、幀率、編碼器等。

---

### 4. 開始處理

輸出位置：

* `output/`
* `audio-out/`（僅音軌提取功能使用）

---

## ⚠️ 注意事項

1. **硬體加速需符合顯示卡驅動要求**
2. CPU 軟編碼相容性佳但速度較慢
3. GIF 檔案通常非常大，建議降低解析度與幀率
4. 若需查看影片資訊，推薦使用 MediaInfo

---
