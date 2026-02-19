# Windows Application Build Instructions

## Quick Build (Automated)

1. **Double-click** `build_windows.bat` in the `flutter` folder
   - This will automatically build the Windows application
   - The executable will be created at: `build\windows\x64\runner\Release\hackathon_app.exe`

## Manual Build Steps

### Prerequisites Check

1. **Verify Flutter is installed:**
   ```bash
   flutter --version
   ```

2. **Check Windows desktop support:**
   ```bash
   flutter doctor -v
   ```
   - Ensure "Windows toolchain" shows as available
   - If not, install Visual Studio 2022 with "Desktop development with C++"

### Build Commands

1. **Open Command Prompt or PowerShell** in the `flutter` directory

2. **Get dependencies:**
   ```bash
   flutter pub get
   ```

3. **Build the release version:**
   ```bash
   flutter build windows --release
   ```

4. **Find your executable:**
   ```
   build\windows\x64\runner\Release\hackathon_app.exe
   ```

## Running the Application

### Option 1: Direct Run
- Navigate to: `build\windows\x64\runner\Release\`
- Double-click `hackathon_app.exe`

### Option 2: Create Portable Package
Copy these files/folders from `Release` folder:
- `hackathon_app.exe`
- `data\` folder (contains flutter_assets)
- All `.dll` files (flutter_windows.dll, etc.)

Zip them together for distribution.

## Troubleshooting

### Error: "Windows desktop support not enabled"
```bash
flutter config --enable-windows-desktop
flutter create --platforms=windows .
```

### Error: "Visual Studio not found"
- Install Visual Studio 2022 Community (free)
- During installation, select "Desktop development with C++" workload
- Restart your computer after installation

### Error: "CMake not found"
- CMake is included with Visual Studio 2022
- Or download separately from: https://cmake.org/download/

### Build fails with C++ errors
- Ensure Visual Studio C++ build tools are installed
- Run: `flutter clean` then `flutter pub get` then rebuild

### Check Flutter setup:
```bash
flutter doctor -v
```

## Build Output Location

```
flutter/
└── build/
    └── windows/
        └── x64/
            └── runner/
                └── Release/
                    ├── hackathon_app.exe  ← Your executable
                    ├── data/
                    └── *.dll files
```

## Notes

- **Release build** is optimized and ready for distribution
- **Debug build** can be created with: `flutter build windows` (without --release)
- The executable is standalone but requires the `data` folder and DLLs to run

