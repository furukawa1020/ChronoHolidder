@echo off
echo ==========================================
echo      ChronoHolidder Launcher
echo ==========================================

echo [1/3] Navigating to app directory...
cd app

echo [2/3] Cleaning and installing dependencies...
call C:\Users\wakuw\Downloads\flutter\bin\flutter.bat clean
call C:\Users\wakuw\Downloads\flutter\bin\flutter.bat pub get

echo [3/3] Launching App...
call C:\Users\wakuw\Downloads\flutter\bin\flutter.bat run

pause
