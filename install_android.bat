@echo off
echo ==========================================
echo      ChronoHolidder Android Installer
echo ==========================================

echo [1/3] Setting up Port Forwarding (ADB Reverse)...
echo Allowing phone to access PC's localhost:8000...
C:\Users\wakuw\AppData\Local\Android\Sdk\platform-tools\adb.exe reverse tcp:8000 tcp:8000
if %errorlevel% neq 0 (
    echo [WARNING] ADB Reverse failed. Is USB Debugging ON?
)

echo.
echo Select Installation Mode:
echo [1] Debug Run (Hot Reload)
echo [2] Install Release APK (Permanent)
echo.
set /p mode="Enter 1 or 2: "

if "%mode%"=="2" (
    echo Installing Release APK...
    C:\Users\wakuw\AppData\Local\Android\Sdk\platform-tools\adb.exe install -r app\build\app\outputs\flutter-apk\app-release.apk
) else (
    echo Starting Debug Run...
    call C:\Users\wakuw\Downloads\flutter\bin\flutter.bat run -d android
)

if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Installation failed.
    echo Please make sure:
    echo 1. USB Debugging is ON
    echo 2. Device Connected
    echo 3. APK is built (if choosing option 2)
    echo.
)

pause
