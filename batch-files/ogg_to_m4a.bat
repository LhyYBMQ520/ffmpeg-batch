@echo off
chcp 65001 >nul
title OGG转M4A转换器
echo ====================================
echo   批量转换OGG到M4A格式
echo ====================================
echo.

:: 设置输入输出目录
set "INPUT_DIR=input"
set "OUTPUT_DIR=output"

:: 检查输入目录是否存在
if not exist "%INPUT_DIR%" (
    echo 错误：输入目录 "%INPUT_DIR%" 不存在！
    echo 请创建一个名为 "%INPUT_DIR%" 的文件夹，并将OGG文件放入其中。
    pause
    exit /b
)

:: 如果输出目录不存在则创建
if not exist "%OUTPUT_DIR%" (
    echo 创建输出目录: %OUTPUT_DIR%
    mkdir "%OUTPUT_DIR%"
)

REM 检查输入目录是否存在OGG文件
if not exist "%INPUT_DIR%\*.ogg" (
    echo 错误：输入目录 "%INPUT_DIR%" 中没有找到 .ogg 文件！
    echo 请将OGG文件放入 "%INPUT_DIR%" 文件夹中。
    pause
    exit /b
)

REM 检查ffmpeg是否可用
where ffmpeg >nul 2>nul
if errorlevel 1 (
    echo 错误：未找到ffmpeg！
    echo 请确保ffmpeg已安装并添加到系统PATH。
    echo 或把ffmpeg.exe放在与此批处理相同的目录。
    pause
    exit /b
)

echo 正在从 %INPUT_DIR% 转换OGG文件到 %OUTPUT_DIR% ...
echo.

REM 记录开始时间
set start_time=%time%

REM 批量转换input目录中的所有OGG文件
for %%f in ("%INPUT_DIR%\*.ogg") do (
    echo 正在转换: "%%~nxf"
    ffmpeg -i "%%f" -c:a aac -b:a 256k -y "%OUTPUT_DIR%\%%~nf.m4a"
    if errorlevel 1 (
        echo 警告: "%%~nxf" 转换失败！
    ) else (
        echo 完成: "%OUTPUT_DIR%\%%~nf.m4a"
    )
    echo.
)

REM 计算处理时间
set end_time=%time%
echo 转换完成！
echo 输入目录: %INPUT_DIR%
echo 输出目录: %OUTPUT_DIR%
echo 开始时间: %start_time%
echo 结束时间: %end_time%
echo.
echo 按任意键退出...
pause >nul