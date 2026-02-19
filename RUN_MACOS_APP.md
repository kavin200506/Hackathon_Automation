# macOS Application - Build Complete! ✅

## Your macOS Application Location

```
flutter/build/macos/Build/Products/Release/hackathon_app.app
```

## How to Run

### Option 1: Double-click (Easiest)
1. Navigate to: `flutter/build/macos/Build/Products/Release/`
2. Double-click `hackathon_app.app`

### Option 2: Command Line
```bash
cd flutter/build/macos/Build/Products/Release
open hackathon_app.app
```

### Option 3: From Project Root
```bash
open flutter/build/macos/Build/Products/Release/hackathon_app.app
```

## Create a DMG Package (Optional)

To create a distributable DMG file:

```bash
# Install create-dmg if needed
brew install create-dmg

# Create DMG
create-dmg \
  --volname "Hackathon App" \
  --window-pos 200 120 \
  --window-size 800 400 \
  --icon-size 100 \
  --icon "hackathon_app.app" 200 190 \
  --hide-extension "hackathon_app.app" \
  --app-drop-link 600 185 \
  "HackathonApp.dmg" \
  "flutter/build/macos/Build/Products/Release/"
```

## App Details

- **Name:** hackathon_app.app
- **Size:** ~42.8 MB
- **Build Type:** Release (optimized)
- **Platform:** macOS (Apple Silicon & Intel compatible)

## Troubleshooting

### "App is damaged" Error
If macOS shows "app is damaged" error:
```bash
xattr -cr flutter/build/macos/Build/Products/Release/hackathon_app.app
```

### Gatekeeper Warning
First time running may show security warning. Go to:
System Settings → Privacy & Security → Allow the app

## Distribution

To share the app:
1. Right-click `hackathon_app.app`
2. Select "Compress"
3. Share the `.zip` file
4. Recipients can extract and run

Or create a DMG (see above) for a more professional distribution.

