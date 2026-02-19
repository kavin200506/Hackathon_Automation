#!/bin/bash

echo "========================================"
echo "Building Hackathon App for macOS"
echo "========================================"
echo ""

echo "Step 1: Getting Flutter dependencies..."
flutter pub get
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to get dependencies"
    exit 1
fi
echo ""

echo "Step 2: Building macOS release..."
flutter build macos --release
if [ $? -ne 0 ]; then
    echo "ERROR: Build failed"
    exit 1
fi
echo ""

echo "========================================"
echo "Build completed successfully!"
echo "========================================"
echo ""
echo "Your macOS app is located at:"
echo "build/macos/Build/Products/Release/hackathon_app.app"
echo ""
echo "To run the app:"
echo "open build/macos/Build/Products/Release/hackathon_app.app"
echo ""

