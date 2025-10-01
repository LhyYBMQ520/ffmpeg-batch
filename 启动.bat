chcp 65001 >nul
@echo off
TITLE FFmpeg Batch
setlocal enabledelayedexpansion

echo ==================================================

echo 欢迎使用 FFmpeg 脚本 (Windows 批处理版本)

echo ==================================================

:: 设置工作目录为批处理文件所在目录
cd /d "%~dp0"

:: 主菜单选择
:main_menu

echo.

echo 请选择功能:

echo 1) 视频转码

echo 2) MP4转GIF动图

echo 3) 提取视频流（仅保留视频，忽略音频）

echo.

set /p "mode_choice=请输入选项编号 (1-3): "  :: 选项范围改为1-3

if "%mode_choice%"=="1" (
    goto select_encode  # 进入原转码流程
) else if "%mode_choice%"=="2" (
    goto gif_conversion  # 进入GIF转换流程
) else if "%mode_choice%"=="3" (
    goto extract_video  # 进入提取视频流流程
) else (

    echo 无效的选择，请重新输入

    timeout /t 1 >nul
    cls
    goto main_menu
)

:: 用户选择源文件编码格式

:select_encode

echo.

echo 请选择源文件的编码格式（推荐使用MediaInfo工具获取源文件详细信息）:

echo 1) H.264
echo 2) HEVC/H.265
echo 3) AV1

echo.

set /p "encode_choice=请输入选项编号 (1-3): "

if "%encode_choice%"=="1" (
    set "SOURCE_ENCODE=h264"
) else if "%encode_choice%"=="2" (
    set "SOURCE_ENCODE=hevc"
) else if "%encode_choice%"=="3" (
    set "SOURCE_ENCODE=av1"
) else (

    echo 无效的选择，请重新输入

    timeout /t 1 >nul
    cls
    goto select_encode
)

:: 用户选择解码方式

echo.

echo 请选择解码方式:

echo 1) cpu软件解码（兼容性最好）

echo 2) NVIDIA显卡硬件解码（CUVID）

echo 3) Intel显卡硬件解码（QSV）

echo 4) AMD显卡硬件解码（AMF）（暂未测试）

echo.

set /p "decode_choice=请输入选项编号 (1-4，默认1): "
if "%decode_choice%"=="" set "decode_choice=1"

if "%decode_choice%"=="1" (
    set "VIDEO_DECODER="

    echo 已选择: CPU软件解码

) else if "%decode_choice%"=="2" (
    set "VIDEO_DECODER=-c:v %SOURCE_ENCODE%_cuvid"

    echo 已选择: NVIDIA硬件解码

) else if "%decode_choice%"=="3" (
    set "VIDEO_DECODER=-c:v %SOURCE_ENCODE%_qsv"

    echo 已选择: Intel硬件解码

) else if "%decode_choice%"=="4" (
    set "VIDEO_DECODER=-c:v %SOURCE_ENCODE%_amf"

    echo 已选择: AMD硬件解码

) else (

    echo 无效的选择，使用默认值: CPU软件解码

    set "decode_choice=1"
    set "VIDEO_DECODER="
)

timeout /t 1 >nul

:: 用户选择目标编码

:select_encode_method

echo.

echo 请选择目标编码

echo 1) H.264
echo 2) HEVC/H.265
echo 3) AV1

echo.

set /p "encoding_method_choice=请输入选项编号 (1-3): "

if "%encoding_method_choice%"=="1" (
    set "TARGET_ENCODE=h264"
) else if "%encoding_method_choice%"=="2" (
    set "TARGET_ENCODE=hevc"
) else if "%encoding_method_choice%"=="3" (
    set "TARGET_ENCODE=av1"
) else (

    echo 无效的选择，请重新输入

    timeout /t 1 >nul
    cls
    goto select_encode_method
)

:: 用户选择编码方式

:select_target_encode

echo.

echo 请选择编码方式:

echo 1) CPU软编码（兼容性最好，但速度慢，资源消耗大）

echo 2) NVIDIA显卡硬件编码(NVENC)

echo 3) Intel显卡硬件编码（QSV）

echo 4) AMD显卡硬件编码（AMF）（暂未测试）

echo.

set /p "target_encode_choice=请输入选项编号 (1-4): "

if "%target_encode_choice%"=="1" (
    set "VIDEO_ENCODER="
) else if "%target_encode_choice%"=="2" (
    set "VIDEO_ENCODER=-c:v %TARGET_ENCODE%_nvenc"
) else if "%target_encode_choice%"=="3" (
    set "VIDEO_ENCODER=-c:v %TARGET_ENCODE%_qsv"
) else if "%target_encode_choice%"=="4" (
    set "VIDEO_ENCODER=-c:v %TARGET_ENCODE%_amf"
) else (

    echo 无效的选择，请重新输入

    timeout /t 1 >nul
    cls
    goto select_target_encode
)

:: 用户选择编码配置

:select_encode_profile

echo.

echo 请选择编码配置（当前仅提供常用配置选项）:

echo 1) main（支持：h264 8位，hevc 8位，av1 8位）

echo 2) high（支持：h264 8位，av1 8位（其实10位也支持，但是不常用:( ）

echo 3) high10（仅h264支持，仅新的intel编解码器支持硬件加速，不爱用:( ）

echo 4) main10（仅hevc支持）

echo.

set /p "encode_profile_choice=请输入选项编号 (1-4): "

if "%encode_profile_choice%"=="1" (
    set "ENCODER_PROFILE=main"
    set "PIXEL_FORMAT=yuv420p"
) else if "%encode_profile_choice%"=="2" (
    set "ENCODER_PROFILE=high"
    set "PIXEL_FORMAT=yuv420p"
) else if "%encode_profile_choice%"=="3" (
    set "ENCODER_PROFILE=high10"
    set "PIXEL_FORMAT=yuv420p10le"
) else if "%encode_profile_choice%"=="4" (
    set "ENCODER_PROFILE=main10"
    set "PIXEL_FORMAT=p010le"
) else (

    echo 无效的选择，请重新输入

    timeout /t 1 >nul
    cls
    goto select_encode_profile
)

:: 视频分辨率选择

:resolution_setting

echo.

echo 是否需要转换视频分辨率？

echo [Y] 需要转换分辨率

echo [N] 保持原始分辨率

echo.

set /p "res_choice=请输入选择 (Y/N，默认N): "

if "%res_choice%"=="" set "res_choice=n"

if /i "%res_choice%"=="y" (
    goto set_resolution
) else if /i "%res_choice%"=="n" (
    set "VIDEO_FILTER="

    echo 已选择保持原始分辨率

    timeout /t 1 >nul
    cls
    goto resolution_done
) else (

    echo 无效输入，请重新选择

    timeout /t 1 >nul
    cls
    goto resolution_setting
)

:set_resolution

echo.

echo 请输入目标分辨率（格式：宽度:高度）

echo 示例: 1920:1080, 1280:720, 3840:2160

echo.

set /p "resolution=请输入分辨率: "

set VIDEO_FILTER=-vf "scale=%resolution%"

echo.

echo 目标分辨率设置完成:

echo 目标分辨率: %resolution%

timeout /t 2 >nul

:resolution_done

:: 码率设置

echo.

echo 请设置视频目标码率（单位：k 或 m）

echo.

echo 编码格式      相对码率比例      说明

echo =================================================

echo H.264/AVC     100%%              基准

echo HEVC/H.265    50-60%%            比H.264节省约40-50%%码率

echo AV1           30-40%%            比H.264节省约60-70%%码率

echo.

echo 示例: 2500k, 5m

echo.

:: 目标码率设置

set /p "target_bitrate=请输入目标码率（默认2500k）: "
if "%target_bitrate%"=="" set "target_bitrate=2500k"

:: 最高码率设置

set /p "max_bitrate=请输入最高码率（一般为目标码率的1.5-2倍）（默认5000k）: "

if "%max_bitrate%"=="" set "max_bitrate=5000k"

:: 缓冲区大小设置

set /p "buffer_size=请输入码率波动缓冲区大小（一般为目标码率的2-4倍）（默认10000k）: "

if "%buffer_size%"=="" set "buffer_size=10000k"

:: 设置最终变量
set "VIDEO_BITRATE=%target_bitrate%"
set "MAX_BITRATE=%max_bitrate%"
set "BUFFER_SIZE=%buffer_size%"

echo.

echo 码率设置完成:

echo 目标码率: %VIDEO_BITRATE%

echo 最高码率: %MAX_BITRATE%

echo 缓冲区大小: %BUFFER_SIZE%

timeout /t 2 >nul

:: 音频流处理参数设置
:audio_setting

echo.

echo 请选择音频流处理方式：

echo 1) 复制音频流（默认，-c:a copy）

echo 2) 忽略音频轨（不保留音频）

echo 3) 自定义参数

echo.

set /p "audio_choice=请输入选项 (1-3，默认1): "
if "%audio_choice%"=="" set "audio_choice=1"

if "%audio_choice%"=="1" (
    set "AUDIO_CODEC=-c:a copy"
) else if "%audio_choice%"=="2" (
    set "AUDIO_CODEC=-an"

    echo 已选择：忽略所有音频轨

) else if "%audio_choice%"=="3" (

    echo.

    echo 请输入自定义音频参数（示例：aac 或 libopus -b:a 192k，不输入默认为copy）

    set /p "audio_input=请输入参数: "
    if not "%audio_input%"=="" (
        set "AUDIO_CODEC=-c:a %audio_input%"
    ) else (
        set "AUDIO_CODEC=-c:a copy"

        echo 未输入参数，默认使用：复制音频流

    )
) else (

    echo 无效的选择，使用默认设置：复制音频流

    set "AUDIO_CODEC=-c:a copy"
    timeout /t 1 >nul
)

:: 字幕流处理参数设置
:subtitle_setting

echo.

echo 请选择字幕流处理方式：

echo 1) 复制字幕流（默认，-c:s copy）

echo 2) 没有字幕流？我要跳过（不处理任何字幕）

echo 3) 自定义字幕参数

echo.

set /p "subtitle_choice=请输入选项 (1-3，默认1): "
if "%subtitle_choice%"=="" set "subtitle_choice=1"

if "%subtitle_choice%"=="1" (
    set "SUBTITLE_CODEC=-c:s copy"
) else if "%subtitle_choice%"=="2" (
    set "SUBTITLE_CODEC="  :: 空参数，不输出任何字幕相关指令

    echo 已选择：跳过所有字幕流

) else if "%subtitle_choice%"=="3" (

    echo.

    echo 请输入自定义字幕参数（示例：mov_text 或 srt，不输入默认为copy）

    set /p "subtitle_input=请输入参数: "
    if not "%subtitle_input%"=="" (
        set "SUBTITLE_CODEC=-c:s %subtitle_input%"
    ) else (
        set "SUBTITLE_CODEC=-c:s copy"

        echo 未输入参数，默认使用：复制字幕流

    )
) else (

    echo 无效的选择，使用默认设置：复制字幕流

    set "SUBTITLE_CODEC=-c:s copy"
    timeout /t 1 >nul
)

echo.

echo 处理参数设置完成:

echo 音频流处理参数: %AUDIO_CODEC%

echo 字幕流处理参数: %SUBTITLE_CODEC%

timeout /t 2 >nul

:: 设置输入输出目录
set "INPUT_DIR=input"
set "OUTPUT_DIR=output"

:: 如果输出目录不存在则创建
if not exist "%OUTPUT_DIR%" (
    echo 创建输出目录: %OUTPUT_DIR%
    mkdir "%OUTPUT_DIR%"
)

:: 批量处理输入目录中的所有文件

echo.

echo 已经一切就绪了，可以开始批量转码...

echo 输入目录: %INPUT_DIR%

echo 输出目录: %OUTPUT_DIR%

echo 文件处理指令预览：ffmpeg %VIDEO_DECODER% -i input file -map 0 %VIDEO_ENCODER% -profile:v %ENCODER_PROFILE% %VIDEO_FILTER% -b:v %VIDEO_BITRATE% -maxrate %MAX_BITRATE% -bufsize %BUFFER_SIZE% -pix_fmt %PIXEL_FORMAT% %AUDIO_CODEC% %SUBTITLE_CODEC% -map_metadata 0 output file

echo.

:: 询问用户是否开始处理文件

:ready

echo.

echo 是否开始处理文件

echo [Y] 开始吧

echo [N] 算了（此操作将会退出批处理）

echo.

set /p "choice=请输入选择 (Y/N，默认N): "

if "%choice%"=="" set "choice=n"

if /i "%choice%"=="y" (
    goto start

) else if /i "%choice%"=="n" (

    echo 已取消操作，将会退出批处理

    timeout /t 1 >nul
    exit

) else (

    echo 无效输入，请重新选择

    timeout /t 1 >nul
    cls
    goto ready
)

:start

:: 计数器
set /a file_count=0
set /a success_count=0
set /a fail_count=0

:: 遍历输入目录中的所有文件，忽略.gitkeep
for %%F in ("%INPUT_DIR%\*.*") do (
    set "INPUT_FILE=%%F"
    set "FILE_NAME=%%~nxF"
    
    :: 检查是否为.gitkeep文件
    if "!FILE_NAME!"==".gitkeep" (

        echo 跳过.gitkeep文件
        
    ) else (
        set "OUTPUT_FILE=%OUTPUT_DIR%\!FILE_NAME!"
        
        echo 正在处理文件: !FILE_NAME!

        echo 输入文件: !INPUT_FILE!

        echo 输出文件: !OUTPUT_FILE!

        echo
        
        ffmpeg ^
          %VIDEO_DECODER% ^
          -i "!INPUT_FILE!" ^
          -map 0 ^
          %VIDEO_ENCODER% ^
          -profile:v %ENCODER_PROFILE% ^
          %VIDEO_FILTER% ^
          -b:v %VIDEO_BITRATE% ^
          -maxrate %MAX_BITRATE% ^
          -bufsize %BUFFER_SIZE% ^
          -pix_fmt %PIXEL_FORMAT% ^
          %AUDIO_CODEC% ^
          %SUBTITLE_CODEC% ^
          -map_metadata 0 ^
          "!OUTPUT_FILE!"
        
        if !errorlevel! equ 0 (

            echo 转码成功: !FILE_NAME!

            set /a success_count+=1
        ) else (

            echo 转码失败: !FILE_NAME!

            set /a fail_count+=1
        )
        
        set /a file_count+=1
        echo.
    )
)

:: 显示处理结果

echo.

echo 批量转码完成!

echo 处理文件总数: %file_count%

echo 成功转码文件数: %success_count%

echo 失败转码文件数: %fail_count%

echo.

if %fail_count% gtr 0 (
    echo 注意: 有 %fail_count% 个文件转码失败，请检查错误信息。
)

pause
goto :eof  # 正常转码流程结束

:: 新增MP4转GIF流程
:gif_conversion

echo ==================================================

echo MP4转GIF批量处理流程

echo ==================================================

:: 设置输入输出目录
set "INPUT_DIR=input"
set "OUTPUT_DIR=output"

:: 如果输出目录不存在则创建
if not exist "%OUTPUT_DIR%" (

    echo 创建输出目录: %OUTPUT_DIR%

    mkdir "%OUTPUT_DIR%"
)

:: GIF分辨率选择
:gif_resolution_setting

echo.

echo 是否需要转换视频分辨率？

echo [Y] 需要转换分辨率

echo [N] 保持原始分辨率

echo.

set /p "res_choice=请输入选择 (Y/N，默认N): "
if "%res_choice%"=="" set "res_choice=n"

if /i "%res_choice%"=="y" (
    goto gif_set_resolution
) else if /i "%res_choice%"=="n" (
    set "GIF_SCALE="

    echo 已选择保持原始分辨率

    timeout /t 1 >nul
    cls
    goto gif_resolution_done
) else (

    echo 无效输入，请重新选择

    timeout /t 1 >nul
    cls
    goto gif_resolution_setting
)

:gif_set_resolution

echo.

echo 请输入目标分辨率（格式：宽度:高度）

echo 示例: 360x360, 640x480, 800x600（GIF建议较小分辨率）

echo.

set /p "resolution=请输入分辨率: "
set "GIF_SCALE=-s %resolution%"

echo.

echo 目标分辨率设置完成:

echo 目标分辨率: %resolution%

timeout /t 2 >nul

:gif_resolution_done

:: 帧率设置
:gif_frame_rate_setting

echo.

echo 是否需要更改帧率？

echo [Y] 需要更改帧率

echo [N] 保持原始帧率（默认）

echo.

set /p "fps_choice=请输入选择 (Y/N，默认N): "
if "%fps_choice%"=="" set "fps_choice=n"

if /i "%fps_choice%"=="y" (
    goto gif_set_frame_rate
) else if /i "%fps_choice%"=="n" (
    set "GIF_FPS="

    echo 已选择保持原始帧率

    timeout /t 1 >nul
    cls
    goto gif_frame_rate_done
) else (

    echo 无效输入，请重新选择

    timeout /t 1 >nul
    cls
    goto gif_frame_rate_setting
)

:gif_set_frame_rate

echo.

echo 请输入目标帧率（示例：10, 15, 20，GIF建议10-15）

echo.

set /p "fps=请输入帧率: "
set "GIF_FPS=-r %fps%"

echo.

echo 目标帧率设置完成: %fps%

timeout /t 2 >nul

:gif_frame_rate_done

:: 显示设置信息
echo.

echo 转换参数设置完成:

if defined GIF_SCALE (echo 分辨率设置: %GIF_SCALE%) else (echo 分辨率设置: 保持原始)

if defined GIF_FPS (echo 帧率设置: %GIF_FPS%) else (echo 帧率设置: 保持原始)

echo 输入目录: %INPUT_DIR%

echo 输出目录: %OUTPUT_DIR%

echo 转换指令预览: ffmpeg -i input.mp4 %GIF_SCALE% %GIF_FPS% output.gif

echo.

:: 询问是否开始转换
:gif_ready

echo 是否开始转换文件？

echo [Y] 开始转换

echo [N] 取消操作（退出）

echo.

set /p "choice=请输入选择 (Y/N，默认N): "
if "%choice%"=="" set "choice=n"

if /i "%choice%"=="y" (
    goto gif_start
) else if /i "%choice%"=="n" (

    echo 已取消操作，退出批处理

    timeout /t 1 >nul
    exit
) else (

    echo 无效输入，请重新选择

    timeout /t 1 >nul
    cls
    goto gif_ready
)

:gif_start
:: 计数器
set /a file_count=0
set /a success_count=0
set /a fail_count=0

:: 遍历输入目录文件并转换为GIF
for %%F in ("%INPUT_DIR%\*.*") do (
    set "INPUT_FILE=%%F"
    set "FILE_NAME=%%~nF"  # 获取文件名（不含扩展名）
    set "FILE_EXT=%%~xF"   # 获取文件扩展名
    
    :: 跳过.gitkeep
    if "!FILE_NAME!!FILE_EXT!"==".gitkeep" (

        echo 跳过.gitkeep文件

    ) else (
        set "OUTPUT_FILE=%OUTPUT_DIR%\!FILE_NAME!.gif"

        echo 正在处理: !FILE_NAME!!FILE_EXT!

        echo 输入文件: !INPUT_FILE!

        echo 输出文件: !OUTPUT_FILE!

        echo.
        
        :: 执行GIF转换命令
        ffmpeg -i "!INPUT_FILE!" %GIF_SCALE% %GIF_FPS% "!OUTPUT_FILE!"
        
        :: 检查执行结果
        if !errorlevel! equ 0 (

            echo 转换成功: !FILE_NAME!.gif

            set /a success_count+=1
        ) else (

            echo 转换失败: !FILE_NAME!.gif

            set /a fail_count+=1
        )
        
        set /a file_count+=1
        echo.
    )
)

:: 显示转换结果
echo.

echo 批量转换完成!

echo 处理文件总数: %file_count%

echo 成功转换文件数: %success_count%

echo 失败转换文件数: %fail_count%

echo.

if %fail_count% gtr 0 (
    echo 注意: 有 %fail_count% 个文件转换失败，请检查错误信息。
)

pause
goto :eof

:: 新增：提取视频流流程（视频copy，音频忽略）
:extract_video

echo ==================================================

echo 提取视频流（仅保留视频，忽略音频）

echo ==================================================

:: 设置输入输出目录（与现有保持一致）
set "INPUT_DIR=input"
set "OUTPUT_DIR=output"

:: 创建输出目录（如果不存在）
if not exist "%OUTPUT_DIR%" (

    echo 创建输出目录: %OUTPUT_DIR%

    mkdir "%OUTPUT_DIR%"
)

echo.

echo 输入目录: %INPUT_DIR%

echo 输出目录: %OUTPUT_DIR%

echo 处理指令预览：ffmpeg -i input.file -c:v copy -an output.file

echo.

:: 询问是否开始处理
:extract_ready

echo 是否开始提取视频流？

echo [Y] 开始处理

echo [N] 取消操作（退出）

echo.

set /p "choice=请输入选择 (Y/N，默认N): "
if "%choice%"=="" set "choice=n"

if /i "%choice%"=="y" (
    goto extract_start
) else if /i "%choice%"=="n" (

    echo 已取消操作，退出批处理

    timeout /t 1 >nul
    exit
) else (

    echo 无效输入，请重新选择
    
    timeout /t 1 >nul
    cls
    goto extract_ready
)

:extract_start
:: 计数器
set /a file_count=0
set /a success_count=0
set /a fail_count=0

:: 遍历输入目录文件，提取视频流
for %%F in ("%INPUT_DIR%\*.*") do (
    set "INPUT_FILE=%%F"
    set "FILE_BASE=%%~nF"
    set "FILE_EXT=%%~xF"
    set "FILE_NAME=%%~nxF"
    
    :: 跳过.gitkeep
    if "!FILE_NAME!"==".gitkeep" (

        echo 跳过.gitkeep文件

    ) else (
        :: 生成带-without-audio后缀的输出文件名
        set "OUTPUT_FILE=%OUTPUT_DIR%\!FILE_BASE!-without-audio!FILE_EXT!"
        
        echo 正在处理: !FILE_NAME!

        echo 输入文件: !INPUT_FILE!

        echo 输出文件: !OUTPUT_FILE!

        echo.
        
        :: 核心命令：复制视频流，忽略音频
        ffmpeg -i "!INPUT_FILE!" -c:v copy -an "!OUTPUT_FILE!"
        
        :: 检查结果（原逻辑不变）
        if !errorlevel! equ 0 (

            echo 提取成功: !FILE_BASE!-without-audio!FILE_EXT!

            set /a success_count+=1
        ) else (

            echo 提取失败: !FILE_NAME!

            set /a fail_count+=1
        )
        
        set /a file_count+=1
        echo.
    )
)

:: 显示结果
echo.

echo 批量提取完成!

echo 处理文件总数: %file_count%

echo 成功提取文件数: %success_count%

echo 失败提取文件数: %fail_count%

echo.

if %fail_count% gtr 0 (

    echo 注意: 有 %fail_count% 个文件提取失败，请检查错误信息。

)

pause
