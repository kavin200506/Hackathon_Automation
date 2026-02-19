@echo off
echo ========================================
echo Building Hackathon App for Windows
echo ========================================
echo.

echo Step 1: Getting Flutter dependencies...
call flutter pub get
if errorlevel 1 (
    echo ERROR: Failed to get dependencies
    pause
    exit /b 1
)
echo.

echo Step 2: Building Windows release...
call flutter build windows --release
if errorlevel 1 (
    echo ERROR: Build failed
    pause
    exit /b 1
)
echo.

echo ========================================
echo Build completed successfully!
echo ========================================
echo.
echo Your executable is located at:
echo build\windows\x64\runner\Release\hackathon_app.exe
echo.
echo To run the app, navigate to:
echo build\windows\x64\runner\Release\
echo and double-click hackathon_app.exe
echo.
pause

