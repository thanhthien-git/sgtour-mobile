#!/bin/bash
# Fix: "unexpected incomplete target: target-sqflite_darwin-sqflite_darwin_privacy"
# Run from project root: bash scripts/ios_clean_rebuild.sh

set -e
echo "Cleaning Flutter..."
flutter clean

echo "Removing iOS Pods and lockfile..."
rm -rf ios/Pods ios/Podfile.lock ios/.symlinks 2>/dev/null || true

echo "Cleaning Xcode DerivedData (optional but recommended)..."
rm -rf ~/Library/Developer/Xcode/DerivedData 2>/dev/null || true

echo "Running flutter pub get..."
flutter pub get

echo "Installing iOS Pods..."
cd ios
pod install --repo-update
cd ..

echo "Done. Try: flutter run (or open ios/Runner.xcworkspace in Xcode and build)."
