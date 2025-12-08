@echo off
echo ==========================================
echo      ChronoHolidder Android Installer
echo ==========================================

echo [1/3] Setting up Port Forwarding (ADB Reverse)...
echo Allowing phone to access PC's localhost:8000...
C:\Users\wakuw\Downloads\flutter\bin\cache\artifacts\engine\windows-x64\platform-tools\adb.exe reverse tcp:8000 tcp:8000
if %errorlevel% neq 0 (
    echo [WARNING] ADB Reverse failed. Is USB Debugging ON?
)

echo [2/3] Building and Installing on connected Android device...
cd app
call C:\Users\wakuw\Downloads\flutter\bin\flutter.bat run -d android

if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Could not install on Android.
    echo Please make sure:
    echo 1. USB Debugging is ON (Developer Options)
    echo 2. USB Cable is connected
    echo 3. You accepted the "Allow USB Debugging" popup on your phone
    echo.
)

pause
