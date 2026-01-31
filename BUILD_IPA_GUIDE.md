# How to Build IPA File for iPhone Installation

## Prerequisites
1. macOS with Xcode installed
2. Apple Developer account (for codesigning)
3. Valid provisioning profile and signing certificate

## Method 1: Using Xcode (Recommended for App Store/Ad-Hoc)

### Steps:
1. **Clean and prepare the project:**
   ```bash
   flutter clean
   flutter pub get
   cd ios
   pod install
   cd ..
   ```

2. **Build iOS release:**
   ```bash
   flutter build ios --release
   ```

3. **Open in Xcode:**
   ```bash
   open ios/Runner.xcworkspace
   ```

4. **In Xcode:**
   - Select "Any iOS Device" or your connected device from the device dropdown
   - Go to **Product → Archive**
   - Wait for the archive to complete
   - The Organizer window will open
   - Select your archive and click **Distribute App**
   - Choose distribution method:
     - **App Store Connect**: For App Store submission
     - **Ad Hoc**: For installation on registered devices
     - **Enterprise**: For enterprise distribution
     - **Development**: For development builds
   - Follow the wizard to export the IPA

## Method 2: Using Flutter CLI (Command Line)

### For Ad-Hoc Distribution:

1. **Build without codesigning:**
   ```bash
   flutter build ios --release --no-codesign
   ```

2. **Create IPA manually:**
   ```bash
   cd build/ios/iphoneos
   mkdir Payload
   cp -r Runner.app Payload/
   zip -r SGTour.ipa Payload
   ```

3. **Note:** This IPA won't be signed and cannot be installed without additional signing.

## Method 3: Automated Script

Create a build script for easier IPA creation:

```bash
#!/bin/bash

# Build the iOS app
flutter clean
flutter pub get
cd ios
pod install
cd ..

# Build iOS release
flutter build ios --release

# Create IPA
cd build/ios/iphoneos
rm -rf Payload
mkdir Payload
cp -r Runner.app Payload/
zip -r ../../../SGTour.ipa Payload
cd ../../..

echo "IPA created at: $(pwd)/SGTour.ipa"
```

## Important Notes:

1. **Codesigning is required** for installation on real devices
2. For **TestFlight/App Store**: Use Xcode's Archive → Distribute App
3. For **Ad-Hoc distribution**: 
   - Register device UDIDs in Apple Developer Portal
   - Create/use Ad-Hoc provisioning profile
   - Use Xcode to archive and export
4. For **development builds**: Connect device and build directly:
   ```bash
   flutter build ios --release
   flutter install
   ```

## Installing IPA on iPhone:

### Using Finder/iTunes (Mac):
- Connect iPhone via USB
- Open Finder, select your iPhone
- Drag and drop the IPA file (limited - requires proper signing)

### Using TestFlight:
- Upload to App Store Connect
- Install via TestFlight app on iPhone

### Using Third-party tools (Ad-Hoc):
- AltStore, Sideloadly, etc. (requires developer account)
- Note: Free Apple Developer accounts have limitations

## Current Bundle Identifier:
`com.sgtour.sgtourcus`

Make sure this matches your Apple Developer account configuration!

---

## How to Reset/Choose Apple Development Team ID

When building iOS apps, you need to select your Apple Development Team. Here are the methods:

### Method 1: Using Xcode (Recommended)

1. **Open the project in Xcode:**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Select the Runner target:**
   - In the left sidebar, click on **Runner** (the blue project icon)
   - Select the **Runner** target (not the project)
   - Click on **Signing & Capabilities** tab

3. **Select/Reset Development Team:**
   - Under **Signing**, check **"Automatically manage signing"**
   - In the **Team** dropdown, select your Apple Developer account
     - If you don't see your team, click "Add Account..." and sign in
     - If you see "Personal Team", select it for development builds
   - Xcode will automatically select/create provisioning profiles

4. **To reset/clear:**
   - Uncheck "Automatically manage signing"
   - Clear the Team dropdown (select "None")
   - Re-check "Automatically manage signing"
   - Select your team again

### Method 2: Using Command Line (Xcode Build Settings)

1. **Open Xcode workspace:**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **In Xcode, set via build settings:**
   - Select Runner target → Build Settings
   - Search for "DEVELOPMENT_TEAM"
   - Set your Team ID (10-character string, e.g., "ABC123DEFG")

3. **Or use xcodebuild command:**
   ```bash
   # Find your team ID first
   # In Xcode: Preferences → Accounts → Select account → Team ID
   
   # Build with specific team
   xcodebuild -workspace ios/Runner.xcworkspace \
              -scheme Runner \
              -configuration Release \
              DEVELOPMENT_TEAM=YOUR_TEAM_ID \
              CODE_SIGN_IDENTITY="Apple Development" \
              build
   ```

### Method 3: Using Flutter CLI with Environment Variables

Set the team ID before building:

```bash
# Export your team ID (get it from Apple Developer portal or Xcode)
export DEVELOPMENT_TEAM="YOUR_TEAM_ID"

# Or for a single build
DEVELOPMENT_TEAM="YOUR_TEAM_ID" flutter build ios --release
```

### Method 4: Directly Edit project.pbxproj (Not Recommended)

⚠️ **Warning**: Editing project files directly can break Xcode integration.

If you must, you can add `DEVELOPMENT_TEAM = "YOUR_TEAM_ID";` to the build settings sections, but it's better to use Xcode.

### Finding Your Team ID:

1. **In Xcode:**
   - Xcode → Preferences (⌘,)
   - Click **Accounts** tab
   - Select your Apple ID
   - Your Team ID is shown in parentheses next to your team name

2. **In Apple Developer Portal:**
   - Visit https://developer.apple.com/account
   - Your Team ID is shown in the top-right corner

### Common Issues:

1. **"No signing certificate found":**
   - Make sure you're logged into Xcode with your Apple ID
   - Xcode → Preferences → Accounts → Add your Apple ID

2. **"Provisioning profile doesn't match":**
   - In Xcode, uncheck "Automatically manage signing"
   - Check it again (forces regeneration)

3. **Multiple teams:**
   - Select the correct team from the dropdown
   - Team ID format: 10 uppercase alphanumeric characters

### Reset Everything:

```bash
# Clean Flutter build
flutter clean

# Clean Xcode derived data
rm -rf ~/Library/Developer/Xcode/DerivedData

# Reopen in Xcode and select team again
open ios/Runner.xcworkspace
```

**Note**: After selecting the team in Xcode, subsequent `flutter build ios` commands will use the selected team automatically.
