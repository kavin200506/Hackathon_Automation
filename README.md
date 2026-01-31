# Cathon Hackathon Platform - Flutter Application

This is the Flutter version of the Hackathon Management System, matching the React application functionality exactly.

## Project Structure

```
flutter/
├── lib/
│   ├── core/              # Constants, theme, utilities
│   ├── services/          # API services
│   ├── models/            # Data models
│   ├── screens/           # All screen pages
│   │   ├── student/       # Student screens
│   │   ├── college/       # College screens
│   │   ├── department/    # Department screens
│   │   └── admin/         # Admin screens
│   ├── widgets/           # Reusable widgets
│   ├── routes/            # Routing configuration
│   ├── store/             # State management
│   └── main.dart          # App entry point
├── assets/                # Images, fonts, etc.
└── pubspec.yaml           # Dependencies
```

## Features

- ✅ Complete API integration matching React app
- ✅ State management with Provider
- ✅ Protected routes with authentication
- ✅ Material 3 design matching Tailwind styles
- ✅ Toast notifications
- ✅ Form validation
- ✅ Error handling

## Prerequisites

- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio / Xcode (for mobile builds)
- VS Code / Android Studio (for development)

## Installation

1. Navigate to the flutter directory:
```bash
cd flutter
```

2. Get dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
# If multiple devices are available, specify one:
flutter run -d macos      # Run on macOS
flutter run -d chrome      # Run on Chrome (web)
flutter run -d android     # Run on Android device/emulator
flutter run -d ios         # Run on iOS device/simulator

# Or use the provided script for macOS:
./run.sh
```

## Platform Support

This Flutter app supports all platforms:

### Android
```bash
flutter build apk              # APK for Android
flutter build appbundle        # App Bundle for Play Store
```

### iOS
```bash
flutter build ios              # iOS build (requires macOS and Xcode)
```

### Web
```bash
flutter build web              # Web build
```

### Windows
```bash
flutter build windows          # Windows executable
```

### macOS
```bash
flutter build macos            # macOS application
```

### Linux
```bash
flutter build linux           # Linux executable
```

## Build Commands

### Development
```bash
flutter run                    # Run on connected device
flutter run -d chrome          # Run on Chrome (web)
flutter run -d windows         # Run on Windows
```

### Production Builds

**Android APK:**
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

**Android App Bundle:**
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

**iOS:**
```bash
flutter build ios --release
# Requires Xcode for final IPA generation
```

**Web:**
```bash
flutter build web --release
# Output: build/web/
```

**Windows:**
```bash
flutter build windows --release
# Output: build/windows/runner/Release/hackathon_app.exe
```

**macOS:**
```bash
flutter build macos --release
# Output: build/macos/Build/Products/Release/hackathon_app.app
```

**Linux:**
```bash
flutter build linux --release
# Output: build/linux/x64/release/bundle/
```

## API Configuration

The app fetches the base URL dynamically from:
- `https://server-url-chi.vercel.app/url`
- Falls back to `http://localhost:8000` if unavailable

## Authentication

The app supports:
- Student authentication
- College authentication
- Department authentication
- Admin authentication

Mock authentication is available for testing:
- Email: `student@test.com`
- Password: `123456`

## State Management

Uses Provider for state management:
- `AuthStore` - Authentication state
- `HackathonStore` - Hackathon data
- `TeamStore` - Team data

## Routing

Uses `go_router` for navigation with protected routes matching React Router behavior.

## Dependencies

Key dependencies:
- `provider` - State management
- `dio` - HTTP client
- `go_router` - Navigation
- `shared_preferences` - Local storage
- `fluttertoast` - Toast notifications
- `intl` - Date/time formatting

## Development

### Running Tests
```bash
flutter test
```

### Code Analysis
```bash
flutter analyze
```

### Format Code
```bash
flutter format .
```

## Troubleshooting

### Build Issues
1. Clean build: `flutter clean && flutter pub get`
2. Check Flutter version: `flutter --version`
3. Verify platform support: `flutter doctor`

### Platform-Specific Issues

**Android:**
- Ensure Android SDK is installed
- Check `android/local.properties` for SDK path

**iOS:**
- Requires macOS
- Install Xcode and CocoaPods
- Run `pod install` in `ios/` directory

**Web:**
- Enable web support: `flutter config --enable-web`

**Desktop:**
- Enable desktop support: `flutter config --enable-windows-desktop` (or macos/linux)

## Notes

- All screens are currently placeholder implementations
- Full functionality matching React app will be implemented incrementally
- API endpoints match the React application exactly
- Theme colors match Tailwind configuration

## License

Same as the main project.
