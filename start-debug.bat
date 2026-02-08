@echo off
REM Quick Debug Script untuk Hotpot POS

echo.
echo ========================================
echo   Hotpot POS - Quick Debug Launcher
echo ========================================
echo.
echo Pilih platform debugging:
echo.
echo 1. Web (Chrome) - RECOMMENDED
echo 2. Web (Chrome) - Fast Mode
echo 3. Clean & Web Debug
echo 4. Show Flutter Doctor
echo 5. Exit
echo.

set /p choice="Pilih nomor (1-5): "

if "%choice%"=="1" (
    echo.
    echo Starting Flutter Web Debugging (Chrome)...
    echo Tunggu 2-3 menit untuk first run
    echo.
    flutter run -d chrome
    goto end
)

if "%choice%"=="2" (
    echo.
    echo Starting Flutter Web Debugging (Fast Mode)...
    echo.
    flutter run -d chrome --fast-start
    goto end
)

if "%choice%"=="3" (
    echo.
    echo Cleaning Flutter project...
    flutter clean
    flutter pub get
    echo.
    echo Starting Flutter Web Debugging...
    flutter run -d chrome
    goto end
)

if "%choice%"=="4" (
    echo.
    flutter doctor -v
    echo.
    pause
    goto menu
)

if "%choice%"=="5" (
    echo Exiting...
    exit /b 0
)

echo Invalid choice!
goto menu

:end
echo.
echo Debug session ended.
echo Tekan enter untuk exit...
pause
