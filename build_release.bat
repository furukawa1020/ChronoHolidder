@echo off
echo ===================================================
echo ChronoHolidder Release Builder
echo ===================================================
echo.
echo This script will build the Android App Bundle (AAB) for Google Play.
echo Ensure you have fully tested the app on an Emulator or Device first.
echo.
pause

cd app

echo.
echo [1/2] Updating dependencies...
call C:\Users\wakuw\Downloads\flutter\bin\flutter.bat pub get

echo.
echo [2/2] Building Release Bundle...
call C:\Users\wakuw\Downloads\flutter\bin\flutter.bat build appbundle --release

echo.
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Build failed! Check the errors above.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo [SUCCESS] Build complete!
echo The AAB file is located at:
echo app\build\app\outputs\bundle\release\app-release.aab
echo.
echo Use the release_workflow.md guide to upload this to the Play Store.
pause
