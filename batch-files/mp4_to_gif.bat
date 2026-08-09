chcp 65001 >nul
@echo off
TITLE FFmpeg MP4转GIF
setlocal enabledelayedexpansion

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
    set "GIF_SCALE_FILTER="
    echo 已选择保持原始分辨率
    timeout /t 1 >nul
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
set "GIF_SCALE_FILTER=scale=!resolution:x=:!:flags=lanczos,"
echo.
echo 目标分辨率设置完成: %resolution%
timeout /t 2 >nul

:gif_resolution_done
:: 帧率设置
:gif_frame_rate_setting
echo.
echo 是否需要更改帧率？

echo [Y] 需要更改帧率

echo [N] 保持原始帧率
echo.
set /p "fps_choice=请输入选择 (Y/N，默认N): "
if "%fps_choice%"=="" set "fps_choice=n"

if /i "%fps_choice%"=="y" (
    goto gif_set_frame_rate
) else if /i "%fps_choice%"=="n" (
    set "GIF_FPS_FILTER="
    echo 已选择保持原始帧率
    timeout /t 1 >nul
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
set "GIF_FPS_FILTER=fps=!fps!,"
echo.
echo 目标帧率设置完成: %fps%
timeout /t 2 >nul

:gif_frame_rate_done
:: 显示设置信息
echo.
echo 转换参数设置完成:
if defined GIF_SCALE_FILTER (echo 分辨率设置: %resolution%) else (echo 分辨率设置: 保持原始)
if defined GIF_FPS_FILTER (echo 帧率设置: %fps%) else (echo 帧率设置: 保持原始)
echo 输入目录: %INPUT_DIR%
echo 输出目录: %OUTPUT_DIR%
echo 转换指令预览: ffmpeg -i input.mp4 -filter_complex "[0:v]fps/scale,split,palettegen/paletteuse" -map "[gif]" -an -loop 0 output.gif
echo.

:: 询问是否开始转换
:gif_ready
echo 是否开始转换文件？

echo [Y] 开始转换

echo [N] 取消操作（返回主菜单）
echo.
set /p "choice=请输入选择 (Y/N，默认N): "
if "%choice%"=="" set "choice=n"

if /i "%choice%"=="y" (
    goto gif_start
) else if /i "%choice%"=="n" (
    echo 已取消操作，返回主菜单
    timeout /t 1 >nul
    exit /b
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
    set "FILE_NAME=%%~nF"
    set "FILE_EXT=%%~xF"
    
    :: 跳过.gitkeep
    if "!FILE_NAME!!FILE_EXT!"==".gitkeep" (
        echo 跳过.gitkeep文件
    ) else (
        set "OUTPUT_FILE=%OUTPUT_DIR%\!FILE_NAME!.gif"

        echo 正在处理: !FILE_NAME!!FILE_EXT!
        echo 输入文件: !INPUT_FILE!
        echo 输出文件: !OUTPUT_FILE!
        echo.
        
        :: 使用单次调色板流程，提高 GIF 的颜色质量。
        ffmpeg -i "!INPUT_FILE!" ^
            -filter_complex "[0:v]!GIF_FPS_FILTER!!GIF_SCALE_FILTER!split[v0][v1];[v0]palettegen=stats_mode=diff[p];[v1][p]paletteuse=dither=sierra2_4a[gif]" ^
            -map "[gif]" ^
            -an ^
            -loop 0 ^
            "!OUTPUT_FILE!"
        
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
exit /b
