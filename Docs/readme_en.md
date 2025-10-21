# FFmpeg Script (Windows Batch Version)

*This readme is translated by Doubao AI*

[English](./readme_en.md) | [中文](../README.md) | [繁体中文](./readme_tcn.md)

This is a simple FFmpeg script that integrates various audio and video processing functions, supports batch operations, and meets the needs of quickly processing daily audio and video files.


## FFmpeg Version Used by the Author (Download Link):
[Windows builds from gyan.dev latest release-full version: 8.0](https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-full.7z)  
(After downloading, extract the file and add the `bin` directory to the system PATH to use it)


### Please report any bugs encountered during use, and I will fix them as soon as possible


## Features

- 🎯 **Video Transcoding**: Supports conversion between H.264, HEVC/H.265, and AV1 formats, with customizable encoding configurations (such as main/high profiles), resolution, bitrate, and other parameters.
- ⚡ **Hardware Acceleration**: Supports CPU software encoding/decoding, as well as hardware encoding/decoding acceleration for NVIDIA (CUVID/NVENC), Intel (QSV), and AMD (AMF) graphics cards.
- 🎞️ **MP4 to GIF Conversion**: One-click conversion of videos to GIFs, supporting custom resolution (smaller sizes recommended) and frame rate (10-15fps recommended to balance file size and smoothness).
- 🎥 **Extract Video Stream**: Quickly strip audio from videos, retaining only the video stream (video is directly copied without re-encoding, ensuring extremely fast speed). Output files are automatically appended with the `-without-audio` suffix.
- 🔊 **Audio Track/Subtitle Processing**: During transcoding, you can choose to copy audio tracks, ignore audio tracks, or customize audio parameters; subtitles support copying, skipping, or custom processing.
- 📁 **Batch Processing**: Automatically reads all files in the `input` directory (ignoring `.gitkeep`), and outputs processed files to the `output` directory.
- 📊 **Progress Statistics**: Displays the number of successful/failed files after each process, facilitating problem troubleshooting.


## System Requirements

- FFmpeg installed and added to the system PATH (it is recommended to use the version from the link above)
- For hardware acceleration: A graphics card from the corresponding brand (NVIDIA/Intel/AMD) is required, with the latest drivers installed


## Usage

### 1. Preparation
Place the files to be processed into the `input` folder (there's no need to delete the `.gitkeep` file, as the script will automatically exclude it during runtime)


### 2. Run the Script
Double-click `启动.bat` (Start.bat) to launch the script, and select a function according to the main menu prompts:
- Enter `1`: Enter the video transcoding process (customizable encoding format, resolution, bitrate, etc.)
- Enter `2`: Enter the MP4 to GIF conversion process (adjustable resolution and frame rate)
- Enter `3`: Enter the video stream extraction process (retain only video, ignore audio)


### 3. Follow the Guide to Complete Settings
Follow the prompts for the selected function to gradually select parameters (such as encoding format, resolution, frame rate, etc.). You can press Enter directly to confirm the default options.


### 4. Start Processing
After confirming the parameters, the script will automatically batch process files in the `input` directory, with results output to the `output` directory.


## Directory Structure

```
Script Directory/
│
├── 启动.bat (Start.bat)    # Main script file
├── input/              # Input directory (stores files to be processed)
│   ├── .gitkeep        # Placeholder file (automatically ignored, no need to delete)
│   └── video_file.mp4  # Video files to be processed (supports multiple formats)
│
└── output/             # Output directory (automatically created)
    ├── transcoded_video.mp4    # Video transcoding results
    ├── animation.gif           # MP4 to GIF conversion results
    └── video-without-audio.mp4  # Video stream extraction results
```


## Notes

1. **Hardware Acceleration Compatibility**:
   - Different graphics cards have different support for encoding formats (e.g., older NVIDIA graphics cards may not support AV1 encoding). If unsure, it is recommended to choose CPU software encoding.
   - If hardware acceleration fails during decoding, you can switch to CPU software decoding (which has the best compatibility).

2. **GIF Conversion Recommendations**:
   - Due to GIF format limitations, it is recommended that the resolution does not exceed 1080p and the frame rate is 10-15fps to avoid excessively large files.

3. **File Formats**:
   - The script will process all files in the `input` directory. Please ensure that the file formats are audio and video formats supported by FFmpeg (such as MP4, MKV, MOV, etc.).

4. **Resource Usage**:
   - Video transcoding (especially CPU software encoding) may consume a large amount of system resources. It is recommended to close other resource-intensive programs during processing.


## Troubleshooting

- If prompted with "ffmpeg is not recognized as an internal or external command": Check if FFmpeg is correctly installed and added to the system PATH.
- Hardware acceleration failure: Try switching to CPU software encoding or updating the graphics card driver.
- Conversion/extraction failure: Check if the input file is corrupted, or try changing parameters (such as reducing resolution, adjusting bitrate).
- No files in the output directory: Confirm that there are valid files (other than `.gitkeep`) in the `input` directory.


## License

This script is open-source under the MIT License and can be freely used and modified.


---

*Tip: It is recommended to use the MediaInfo tool to check the source file encoding information before use to select parameters more accurately.*
