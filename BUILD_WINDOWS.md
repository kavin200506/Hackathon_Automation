# Building Windows Application

## Prerequisites

1. **Flutter SDK** (latest stable version)
   - Download from: https://flutter.dev/docs/get-started/install/windows
   - Add Flutter to your PATH

2. **Visual Studio 2022** (or Visual Studio Build Tools)
   - Install with "Desktop development with C++" workload
   - Required for Windows desktop development

3. **Git** (if not already installed)

## Build Steps

1. **Open Command Prompt or PowerShell** in the `flutter` directory

2. **Get dependencies:**
   ```bash
   flutter pub get
   ```

3. **Build the Windows application:**
   ```bash
   flutter build windows --release
   ```

4. **Find the executable:**
   The built application will be located at:
   ```
   build\windows\x64\runner\Release\hackathon_app.exe
   ```

## Running the Application

1. Navigate to: `build\windows\x64\runner\Release\`
2. Double-click `hackathon_app.exe` to run

## Creating a Portable Package

To create a portable package that can be distributed:

1. Copy the entire `Release` folder contents:
   - `hackathon_app.exe`
   - `data` folder
   - `flutter_windows.dll` (and other DLL files)

2. Zip the contents and distribute

## Troubleshooting

- If you get "Windows desktop support not enabled", run:
  ```bash
  flutter config --enable-windows-desktop
  flutter create --platforms=windows .
  ```

- If build fails, ensure Visual Studio C++ tools are installed
- Check Flutter doctor: `flutter doctor -v`

