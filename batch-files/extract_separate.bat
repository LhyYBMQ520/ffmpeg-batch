chcp 65001 >nul
@echo off
TITLE 提取视频流与音频流
setlocal enabledelayedexpansion

echo ==================================================
echo 功能：提取纯视频流 + 分离音频流
echo ==================================================

:: 设置目录
set "INPUT_DIR=input"
set "OUTPUT_VIDEO_DIR=output"
set "OUTPUT_AUDIO_DIR=audio-out"

:: 创建目录
if not exist "%OUTPUT_VIDEO_DIR%" mkdir "%OUTPUT_VIDEO_DIR%"
if not exist "%OUTPUT_AUDIO_DIR%" mkdir "%OUTPUT_AUDIO_DIR%"

:: 显示信息

echo 输入目录：%INPUT_DIR%

echo 视频输出：%OUTPUT_VIDEO_DIR%（文件名加-video-only）

echo 音频输出：%OUTPUT_AUDIO_DIR%（自动使用正确后缀）
echo.

:: 询问开始

:start_ask

set /p "choice=是否开始处理？(Y/N，默认N): "
if "%choice%"=="" set "choice=n"
if /i "%choice%"=="y" goto process
if /i "%choice%"=="n" exit /b
echo 无效输入，请重新选择
goto start_ask

:process
:: 计数器
set /a total=0, v_ok=0, v_err=0, a_ok=0, a_err=0

:: 遍历文件
for %%F in ("%INPUT_DIR%\*.*") do (
    set "file=%%F"
    set "name=%%~nF"
    set "ext=%%~xF"
    set "fullname=%%~nxF"
    
    :: 跳过.gitkeep
    if "!fullname!"==".gitkeep" (
        echo.
        echo 已跳过.gitkeep

    ) else (
        echo.
        echo 处理文件：!fullname!
        set /a total+=1

        :: 1. 提取视频
        set "v_out=%OUTPUT_VIDEO_DIR%\!name!-video-only!ext!"

        echo 视频输出：!v_out!
        echo.

        ffmpeg -y -hide_banner -i "!file!" -c:v copy -an "!v_out!"
        if !errorlevel! equ 0 (set /a v_ok+=1 & echo 视频提取成功) else (set /a v_err+=1 & echo 视频提取失败)

        :: 2. 提取音频流（使用临时 log）
        ffprobe -v error -select_streams a -show_entries stream=codec_name -of csv=p=0 "!file!" > audio.tmp 2>&1

        echo.
        echo audio.tmp 内容：

        type audio.tmp

        echo 以上为 audio.tmp 内容
        echo.

        :: 遍历每一行，每条音轨
        set /a track_index=0
        for /f "usebackq tokens=*" %%a in ("audio.tmp") do (
            set /a track_index+=1
            set "a_codec=%%a"

            :: 根据编码选择后缀
            set "a_ext=!a_codec!"
            if /i "!a_codec!"=="aac" set "a_ext=m4a"
            if /i "!a_codec!"=="mp3" set "a_ext=mp3"
            if /i "!a_codec!"=="opus" set "a_ext=ogg"
            if /i "!a_codec!"=="flac" set "a_ext=flac"
            if /i "!a_codec!"=="wav" set "a_ext=wav"
            if /i "!a_codec!"=="ac3" set "a_ext=ac3"
            if /i "!a_codec!"=="eac3" set "a_ext=eac3"
            if /i "!a_codec!"=="vorbis" set "a_ext=ogg"
            if /i "!a_codec!"=="dts" set "a_ext=dts"
            if /i "!a_codec!"=="mp2" set "a_ext=mp2"

            :: 输出文件名加轨道编号
            set "a_out=%OUTPUT_AUDIO_DIR%\!name!-audio!track_index!.!a_ext!"

            :: 计算 FFmpeg 音轨索引
            set /a ff_index=track_index-1

            echo 提取音轨 !track_index! 编码：!a_codec!
            echo 输出文件：!a_out!

            :: 提取对应音轨
            ffmpeg -y -hide_banner -i "!file!" -map 0:a:!ff_index! -c:a copy -vn "!a_out!"
            if !errorlevel! equ 0 (
                set /a a_ok+=1
                echo 音轨 !track_index! 提取成功
            ) else (
                set /a a_err+=1
                echo 音轨 !track_index! 提取失败
            )
        )
    )
)

del audio.tmp


:: 结果统计
echo.
echo ==================================================

echo 处理完成！

echo 总文件数：%total%

echo 视频：成功%v_ok%个，失败%v_err%个

echo 音频：成功%a_ok%个，失败%a_err%个

echo ==================================================

echo 提示：音频文件已自动使用对应扩展名
echo.

pause
exit /b
