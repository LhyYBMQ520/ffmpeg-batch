@echo off
chcp 65001 >nul
title MKV转MP4批量转换工具
echo ===============================================
echo    MKV转MP4批量转换工具
echo ===============================================
echo.

:: 设置输入输出目录
set "INPUT_DIR=input"
set "OUTPUT_DIR=output"

:: 检查输入目录是否存在
if not exist "%INPUT_DIR%" (
    echo 错误：输入目录 "%INPUT_DIR%" 不存在！
    echo 请创建一个名为 "%INPUT_DIR%" 的文件夹，并将MKV文件放入其中。
    pause
    exit /b
)

:: 如果输出目录不存在则创建
if not exist "%OUTPUT_DIR%" (
    echo 创建输出目录: %OUTPUT_DIR%
    mkdir "%OUTPUT_DIR%"
)

:: 检查输入目录是否存在MKV文件
if not exist "%INPUT_DIR%\*.mkv" (
    echo 错误：输入目录 "%INPUT_DIR%" 中没有找到 .mkv 文件！
    echo 请将MKV文件放入 "%INPUT_DIR%" 文件夹中。
    pause
    exit /b
)

:: 检查ffmpeg是否可用
where ffmpeg >nul 2>nul
if errorlevel 1 (
    echo 错误：未找到ffmpeg！
    echo 请确保ffmpeg已安装并添加到系统PATH。
    echo 或把ffmpeg.exe放在与此批处理相同的目录。
    pause
    exit /b
)

echo 正在从 %INPUT_DIR% 转换MKV文件到 %OUTPUT_DIR% ...
echo 转换将尽可能无损保留音视频流...
echo.

:: 记录开始时间
set start_time=%time%

:: 批量转换input目录中的所有MKV文件
for %%f in ("%INPUT_DIR%\*.mkv") do (
    echo 正在转换: "%%~nxf"
    
    :: 主转换命令：无损复制音视频流
    ffmpeg -i "%%f" ^
        -c:v copy ^
        -c:a copy ^
        -c:s mov_text ^
        -map 0 ^
        -movflags +faststart ^
        -strict experimental ^
        -y "%OUTPUT_DIR%\%%~nf.mp4" 2>nul
    
    if errorlevel 1 (
        echo 主方法失败，尝试备选方案...
        
        :: 备选方案：尝试不转换字幕
        ffmpeg -i "%%f" ^
            -c:v copy ^
            -c:a copy ^
            -map 0 ^
            -movflags +faststart ^
            -strict experimental ^
            -y "%OUTPUT_DIR%\%%~nf.mp4" 2>nul
        
        if errorlevel 1 (
            echo 备选方案也失败，尝试最终方案...
            
            :: 最终方案：跳过字幕
            ffmpeg -i "%%f" ^
                -c:v copy ^
                -c:a copy ^
                -movflags +faststart ^
                -y "%OUTPUT_DIR%\%%~nf.mp4" 2>nul
        )
    )
    
    if not errorlevel 1 (
        echo 转换成功: "%OUTPUT_DIR%\%%~nf.mp4"
    ) else (
        echo 警告: "%%~nxf" 转换失败！
    )
    echo.
)

:: 计算处理时间
set end_time=%time%
echo 转换完成！
echo 输入目录: %INPUT_DIR%
echo 输出目录: %OUTPUT_DIR%
echo 开始时间: %start_time%
echo 结束时间: %end_time%
echo.
echo 按任意键退出...
pause >nul