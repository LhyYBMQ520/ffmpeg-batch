chcp 65001 >nul
@echo off
TITLE FFmpeg 视频转码/压缩
setlocal enabledelayedexpansion

echo ==================================================
echo 视频转码/压缩功能
echo ==================================================

echo.
echo 源视频编码将由 FFprobe 自动检测（支持混合 H.264、HEVC、AV1 输入）。

:: 用户选择解码方式
echo.
echo 请选择解码方式:

echo 1) cpu软件解码（兼容性最好）

echo 2) NVIDIA显卡硬件解码（CUVID）

echo 3) Intel显卡硬件解码（QSV）

echo 4) AMD显卡硬件解码（AMF）
echo.
set /p "decode_choice=请输入选项编号 (1-4，默认1): "
if "%decode_choice%"=="" set "decode_choice=1"

if "%decode_choice%"=="1" (
    set "DECODER_MODE=cpu"
    echo 已选择: CPU软件解码
) else if "%decode_choice%"=="2" (
    set "DECODER_MODE=cuvid"
    echo 已选择: NVIDIA硬件解码
) else if "%decode_choice%"=="3" (
    set "DECODER_MODE=qsv"
    echo 已选择: Intel硬件解码
) else if "%decode_choice%"=="4" (
    set "DECODER_MODE=amf"
    echo 已选择: AMD硬件解码
) else (
    echo 无效的选择，使用默认值: CPU软件解码
    set "decode_choice=1"
    set "DECODER_MODE=cpu"
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

echo 1) CPU软编码（兼容性最好）

echo 2) NVIDIA显卡硬件编码(NVENC)

echo 3) Intel显卡硬件编码（QSV）

echo 4) AMD显卡硬件编码（AMF）
echo.
set /p "target_encode_choice=请输入选项编号 (1-4): "

:: 根据目标编码和选择的方式，设置对应的编码器参数
if "%target_encode_choice%"=="1" (
    :: CPU软编码：根据目标编码选择主流编码器
    if "%TARGET_ENCODE%"=="h264" (
        set "VIDEO_ENCODER=-c:v libx264"
    ) else if "%TARGET_ENCODE%"=="hevc" (
        set "VIDEO_ENCODER=-c:v libx265"
    ) else if "%TARGET_ENCODE%"=="av1" (
        set "VIDEO_ENCODER=-c:v libsvtav1"
    )
) else if "%target_encode_choice%"=="2" (
    :: NVIDIA NVENC硬件编码
    set "VIDEO_ENCODER=-c:v %TARGET_ENCODE%_nvenc"
) else if "%target_encode_choice%"=="3" (
    :: Intel QSV硬件编码
    set "VIDEO_ENCODER=-c:v %TARGET_ENCODE%_qsv"
) else if "%target_encode_choice%"=="4" (
    :: AMD AMF硬件编码
    set "VIDEO_ENCODER=-c:v %TARGET_ENCODE%_amf"
) else (
    echo 无效的选择，请重新输入
    timeout /t 1 >nul
    cls
    goto select_target_encode
)

:: 调试输出（可选，用于验证参数是否正确）
echo.
echo 已选择编码器参数：%VIDEO_ENCODER%
echo.

:: 用户选择编码配置
:select_encode_profile
if /i "%TARGET_ENCODE%"=="av1" (
    set "ENCODER_PROFILE=main"
    set "PIXEL_FORMAT=yuv420p"
    set "PROFILE_ARG="
    echo AV1自动使用main配置，跳过profile参数设置。
    goto profile_done
)

echo.
echo 请选择编码配置（当前仅提供常用配置选项）:

echo 1) main（支持：h264 8位，hevc 8位，av1 8位）

echo 2) high（支持：h264 8位，av1 8位）

echo 3) high10（仅h264支持）

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

set "PROFILE_ARG=-profile:v %ENCODER_PROFILE%"

:profile_done

:: 用户选择目标容器
:select_container
echo.
echo 请选择目标容器:

echo 1) MKV（兼容性最好，默认）

echo 2) MP4（适合 H.264/HEVC、AAC）

echo 3) WebM（适合 AV1、Opus）

echo.
set /p "container_choice=请输入选项编号 (1-3，默认1): "
if "%container_choice%"=="" set "container_choice=1"

if "%container_choice%"=="1" (
    set "TARGET_CONTAINER=mkv"
    set "OUTPUT_EXT=.mkv"
    set "OUTPUT_FORMAT=matroska"
) else if "%container_choice%"=="2" (
    set "TARGET_CONTAINER=mp4"
    set "OUTPUT_EXT=.mp4"
    set "OUTPUT_FORMAT=mp4"
) else if "%container_choice%"=="3" (
    set "TARGET_CONTAINER=webm"
    set "OUTPUT_EXT=.webm"
    set "OUTPUT_FORMAT=webm"
) else (
    echo 无效的选择，请重新输入
    timeout /t 1 >nul
    cls
    goto select_container
)

if /i "%TARGET_CONTAINER%"=="webm" if /i not "%TARGET_ENCODE%"=="av1" (
    echo WebM容器仅支持当前列表中的AV1目标编码，请重新选择容器
    timeout /t 2 >nul
    cls
    goto select_container
)

echo 已选择目标容器: %TARGET_CONTAINER%
timeout /t 1 >nul

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
echo 目标分辨率设置完成: %resolution%
timeout /t 1 >nul

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


:: 设置最终变量
set "VIDEO_BITRATE=%target_bitrate%"
set "MAX_BITRATE=%max_bitrate%"

:: 根据最高码率自动计算两倍大小的缓冲区
set "MAX_BITRATE_NUMBER=%max_bitrate%"
set "MAX_BITRATE_UNIT="
if /i "%max_bitrate:~-1%"=="k" (
    set "MAX_BITRATE_NUMBER=%max_bitrate:~0,-1%"
    set "MAX_BITRATE_UNIT=k"
) else if /i "%max_bitrate:~-1%"=="m" (
    set "MAX_BITRATE_NUMBER=%max_bitrate:~0,-1%"
    set "MAX_BITRATE_UNIT=m"
)
set /a BUF_SIZE_NUMBER=MAX_BITRATE_NUMBER*2
if defined MAX_BITRATE_UNIT (
    set "BUF_SIZE=%BUF_SIZE_NUMBER%%MAX_BITRATE_UNIT%"
) else (
    set "BUF_SIZE=%BUF_SIZE_NUMBER%"
)

echo.
echo 码率设置完成:
echo 目标码率: %VIDEO_BITRATE%
echo 最高码率: %MAX_BITRATE%
echo 缓冲区大小: %BUF_SIZE%
timeout /t 1 >nul

:: 音频流处理参数设置
:audio_setting
set "AUDIO_COPY_LABEL=复制音频流（默认，-c:a copy）"
if /i "%TARGET_CONTAINER%"=="webm" set "AUDIO_COPY_LABEL=复制音频流（WebM将自动转为Opus，-c:a libopus）"
echo.
echo 请选择音频流处理方式：

echo 1) %AUDIO_COPY_LABEL%

echo 2) 忽略音频轨（不保留音频）

echo 3) 自定义参数
echo.
set /p "audio_choice=请输入选项 (1-3，默认1): "
if "%audio_choice%"=="" set "audio_choice=1"

if "%audio_choice%"=="1" (
    set "AUDIO_MAP=-map 0:a?"
    set "AUDIO_CODEC=-c:a copy"
) else if "%audio_choice%"=="2" (
    set "AUDIO_MAP="
    set "AUDIO_CODEC=-an"
    echo 已选择：忽略所有音频轨
) else if "%audio_choice%"=="3" (
    echo.
    echo 请输入自定义音频参数（示例：aac 或 libopus -b:a 192k，不输入默认为copy）
    
    set /p "audio_input=请输入参数: "
    if not "%audio_input%"=="" (
        set "AUDIO_MAP=-map 0:a?"
        set "AUDIO_CODEC=-c:a %audio_input%"
    ) else (
        set "AUDIO_MAP=-map 0:a?"
        set "AUDIO_CODEC=-c:a copy"
        echo 未输入参数，默认使用：复制音频流
    )
) else (
    echo 无效的选择，使用默认设置：复制音频流
    set "AUDIO_MAP=-map 0:a?"
    set "AUDIO_CODEC=-c:a copy"
    timeout /t 1 >nul
)

:: 字幕流处理参数设置
:subtitle_setting
set "SUBTITLE_COPY_LABEL=复制字幕流（-c:s copy）"
if /i "%TARGET_CONTAINER%"=="mp4" set "SUBTITLE_COPY_LABEL=复制字幕流（MP4将自动转为mov_text，-c:s mov_text）"
if /i "%TARGET_CONTAINER%"=="webm" set "SUBTITLE_COPY_LABEL=复制字幕流（WebM将自动转为WebVTT，-c:s webvtt）"
echo.
echo 请选择字幕流处理方式：

echo 1) 没有字幕流？我要跳过（默认）

echo 2) %SUBTITLE_COPY_LABEL%

echo 3) 自定义字幕参数
echo.
set /p "subtitle_choice=请输入选项 (1-3，默认1): "
if "%subtitle_choice%"=="" set "subtitle_choice=1"

if "%subtitle_choice%"=="1" (
    set "SUBTITLE_MAP="
    set "SUBTITLE_CODEC=-sn"
    echo 已选择：跳过所有字幕流
) else if "%subtitle_choice%"=="2" (
    set "SUBTITLE_MAP=-map 0:s?"
    set "SUBTITLE_CODEC=-c:s copy"
) else if "%subtitle_choice%"=="3" (
    echo.
    echo 请输入自定义字幕参数（示例：mov_text 或 srt，不输入默认为copy）
    
    set /p "subtitle_input=请输入参数: "
    if not "%subtitle_input%"=="" (
        set "SUBTITLE_MAP=-map 0:s?"
        set "SUBTITLE_CODEC=-c:s %subtitle_input%"
    ) else (
        set "SUBTITLE_MAP=-map 0:s?"
        set "SUBTITLE_CODEC=-c:s copy"
        echo 未输入参数，默认使用：复制字幕流
    )
) else (
    echo 无效的选择，使用默认设置：跳过所有字幕流
    set "subtitle_choice=1"
    set "SUBTITLE_MAP="
    set "SUBTITLE_CODEC=-sn"
    timeout /t 1 >nul
)

if "%subtitle_choice%"=="1" (
    set "ATTACHMENT_CHOICE=2"
    set "ATTACHMENT_ARGS="
    goto attachment_done
)

:attachment_setting
echo.
echo 是否复制字体附件？（ASS字幕通常需要字体附件）
echo 1) 复制字体附件（默认）

echo 2) 不复制字体附件
echo.
set /p "attachment_choice=请输入选项 (1-2，默认1): "
if "%attachment_choice%"=="" set "attachment_choice=1"

if "%attachment_choice%"=="1" (
    set "ATTACHMENT_CHOICE=1"
    set "ATTACHMENT_ARGS=-map 0:t? -c:t copy"
    echo 已选择：复制字体附件（仅对MKV输出生效）
) else if "%attachment_choice%"=="2" (
    set "ATTACHMENT_CHOICE=2"
    set "ATTACHMENT_ARGS="
    echo 已选择：不复制字体附件
) else (
    echo 无效输入，请重新选择
    timeout /t 1 >nul
    goto attachment_setting
)

:attachment_done

:: 按目标容器调整不兼容的流编码
if /i "%TARGET_CONTAINER%"=="mp4" (
    if not "%subtitle_choice%"=="1" set "SUBTITLE_CODEC=-c:s mov_text"
    set "ATTACHMENT_CHOICE=2"
    set "ATTACHMENT_ARGS="
    echo.
    echo 提示：MP4不支持ASS字幕和字体附件，字幕将转换为mov_text，字体附件不复制。
)
if /i "%TARGET_CONTAINER%"=="webm" (
    if "%audio_choice%"=="1" set "AUDIO_CODEC=-c:a libopus"
    if not "%subtitle_choice%"=="1" set "SUBTITLE_CODEC=-c:s webvtt"
    set "ATTACHMENT_CHOICE=2"
    set "ATTACHMENT_ARGS="
    echo.
    echo 提示：WebM将使用Opus音频和WebVTT字幕，字体附件不复制。
)

echo.
echo 处理参数设置完成:
echo.
echo 音频流处理参数: %AUDIO_CODEC%
echo 字幕流处理参数: %SUBTITLE_CODEC%
if "%ATTACHMENT_CHOICE%"=="1" (echo 字体附件: MKV输出时复制) else (echo 字体附件: 不复制)
echo.
timeout /t 2 >nul

:: 设置输入输出目录
set "INPUT_DIR=input"
set "OUTPUT_DIR=output"

:: 如果输出目录不存在则创建
if not exist "%OUTPUT_DIR%" (
    echo 创建输出目录: %OUTPUT_DIR%
    mkdir "%OUTPUT_DIR%"
)

:: 显示处理信息
echo.
echo 已经一切就绪了，可以开始批量转码...

echo 输入目录: %INPUT_DIR%

echo 输出目录: %OUTPUT_DIR%

echo 目标容器: %TARGET_CONTAINER%（输出扩展名: %OUTPUT_EXT%）

echo 文件处理指令预览：ffmpeg [按文件自动选择解码器] -i input file -map 0:V:0? %AUDIO_MAP% %SUBTITLE_MAP% %ATTACHMENT_ARGS% %VIDEO_ENCODER% %PROFILE_ARG% %VIDEO_FILTER% -b:v %VIDEO_BITRATE% -maxrate %MAX_BITRATE% -bufsize %BUF_SIZE% -pix_fmt %PIXEL_FORMAT% %AUDIO_CODEC% %SUBTITLE_CODEC% -map_metadata 0 -metadata:s:v BPS= -metadata:s:v DURATION= -metadata:s:v NUMBER_OF_BYTES= -metadata:s:v NUMBER_OF_FRAMES= -metadata:s:v _STATISTICS_TAGS= -metadata:s:v _STATISTICS_WRITING_APP= -metadata:s:v _STATISTICS_WRITING_DATE_UTC= output file
echo.

:: 询问用户是否开始处理文件
:ready
echo.
echo 是否开始处理文件

echo [Y] 开始吧

echo [N] 算了（此操作将会返回主菜单）
echo.
set /p "choice=请输入选择 (Y/N，默认N): "
if "%choice%"=="" set "choice=n"

if /i "%choice%"=="y" (
    goto start
) else if /i "%choice%"=="n" (
    echo 已取消操作，返回主菜单
    timeout /t 1 >nul
    exit /b
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
        set "OUTPUT_FILE=%OUTPUT_DIR%\%%~nF!OUTPUT_EXT!"
        set "ATTACHMENT_ARGS="
        if /i "!TARGET_CONTAINER!"=="mkv" if "!ATTACHMENT_CHOICE!"=="1" set "ATTACHMENT_ARGS=-map 0:t? -c:t copy"
        
        echo 正在处理文件: !FILE_NAME!
        echo 输入文件: !INPUT_FILE!
        echo 输出文件: !OUTPUT_FILE!
        echo.

        set "SOURCE_ENCODE="
        ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of csv=p=0 "!INPUT_FILE!" > video_codec.tmp

        if errorlevel 1 (
            echo 视频编码检测失败，跳过文件: !FILE_NAME!
            set /a fail_count+=1
        ) else (
            set /p "SOURCE_ENCODE="<video_codec.tmp

            if not defined SOURCE_ENCODE (
                echo 未检测到视频流，跳过文件: !FILE_NAME!
                set /a fail_count+=1
            ) else (
                set "VIDEO_DECODER="

                if "!DECODER_MODE!"=="cuvid" (
                    if /i "!SOURCE_ENCODE!"=="h264" set "VIDEO_DECODER=-c:v h264_cuvid"
                    if /i "!SOURCE_ENCODE!"=="hevc" set "VIDEO_DECODER=-c:v hevc_cuvid"
                    if /i "!SOURCE_ENCODE!"=="av1" set "VIDEO_DECODER=-c:v av1_cuvid"
                )
                if "!DECODER_MODE!"=="qsv" (
                    if /i "!SOURCE_ENCODE!"=="h264" set "VIDEO_DECODER=-c:v h264_qsv"
                    if /i "!SOURCE_ENCODE!"=="hevc" set "VIDEO_DECODER=-c:v hevc_qsv"
                    if /i "!SOURCE_ENCODE!"=="av1" set "VIDEO_DECODER=-c:v av1_qsv"
                )
                if "!DECODER_MODE!"=="amf" (
                    if /i "!SOURCE_ENCODE!"=="h264" set "VIDEO_DECODER=-c:v h264_amf"
                    if /i "!SOURCE_ENCODE!"=="hevc" set "VIDEO_DECODER=-c:v hevc_amf"
                    if /i "!SOURCE_ENCODE!"=="av1" set "VIDEO_DECODER=-c:v av1_amf"
                )

                echo 检测到源视频编码: !SOURCE_ENCODE!
                timeout /t 2 >nul

                set "DECODER_READY="
                if "!DECODER_MODE!"=="cpu" set "DECODER_READY=1"
                if defined VIDEO_DECODER set "DECODER_READY=1"

                if not defined DECODER_READY (
                    echo 所选硬件解码方式不支持该编码，跳过文件: !FILE_NAME!
                    set /a fail_count+=1
                ) else (
                    ffmpeg ^
                      !VIDEO_DECODER! ^
                      -i "!INPUT_FILE!" ^
                      -map 0:V:0? ^
                      %AUDIO_MAP% ^
                      %SUBTITLE_MAP% ^
                      !ATTACHMENT_ARGS! ^
                      %VIDEO_ENCODER% ^
                      %PROFILE_ARG% ^
                      %VIDEO_FILTER% ^
                      -b:v %VIDEO_BITRATE% ^
                      -maxrate %MAX_BITRATE% ^
                      -bufsize %BUF_SIZE% ^
                      -pix_fmt %PIXEL_FORMAT% ^
                      %AUDIO_CODEC% ^
                      %SUBTITLE_CODEC% ^
                      -map_metadata 0 ^
                      -metadata:s:v BPS= ^
                      -metadata:s:v DURATION= ^
                      -metadata:s:v NUMBER_OF_BYTES= ^
                      -metadata:s:v NUMBER_OF_FRAMES= ^
                      -metadata:s:v _STATISTICS_TAGS= ^
                      -metadata:s:v _STATISTICS_WRITING_APP= ^
                      -metadata:s:v _STATISTICS_WRITING_DATE_UTC= ^
                      -f %OUTPUT_FORMAT% ^
                      "!OUTPUT_FILE!"

                    if !errorlevel! equ 0 (
                        echo 转码成功: !FILE_NAME!
                        set /a success_count+=1
                    ) else (
                        echo 转码失败: !FILE_NAME!
                        set /a fail_count+=1
                    )
                )
            )
        )
        
        set /a file_count+=1
        echo.
    )
)

del video_codec.tmp 2>nul

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
exit /b
