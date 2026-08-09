chcp 65001 >nul
@echo off
TITLE FFmpeg Batch
setlocal enabledelayedexpansion

echo ==================================================
echo 欢迎使用 FFmpeg 脚本工具集 (Windows 批处理版本)
echo ==================================================

:: 设置工作目录为批处理文件所在目录
cd /d "%~dp0"

:main_menu
echo.
echo 请选择功能:
echo 1) 视频转码/压缩

echo 2) MP4转GIF动图

echo 3) 分离音视频流
echo.

set /p "mode_choice=请输入选项编号 (1-3): "

if "%mode_choice%"=="1" (
    call batch-files\encode.bat
) else if "%mode_choice%"=="2" (
    call batch-files\mp4_to_gif.bat
) else if "%mode_choice%"=="3" (
    call batch-files\extract_separate.bat
) else (
    echo 无效的选择，请重新输入
    timeout /t 1 >nul
    cls
    goto main_menu
)

echo.
echo 操作已完成，返回主菜单...
timeout /t 2 >nul
cls
goto main_menu
