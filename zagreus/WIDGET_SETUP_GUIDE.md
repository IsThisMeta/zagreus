# Home Screen Widget Setup Guide

This guide will help you add the Upcoming Movies & Shows widget to your iOS home screen.

## What We've Built

- **Flutter Service**: `lib/services/upcoming_widget_service.dart` - Fetches upcoming content from TMDB
- **iOS Widget**: `ios/UpcomingWidget/UpcomingWidget.swift` - Native SwiftUI widget
- **3 Widget Sizes**: Small (next item), Medium (3 items), Large (5 items)
- **Auto-refresh**: Updates every 4 hours automatically
- **Manual refresh**: Called on app launch

## Xcode Setup (Required)

You need to add the widget extension target in Xcode. Here's how:

### Step 1: Open Project in Xcode

```bash
cd /Users/umikaze/Projects/zagreus/zagreus/ios
open Runner.xcworkspace
```

### Step 2: Add Widget Extension Target

1. In Xcode, click **File → New → Target**
2. Select **Widget Extension** under iOS
3. Click **Next**
4. Configure the extension:
   - **Product Name**: `UpcomingWidget`
   - **Team**: Your development team
   - **Organization Identifier**: `com.zebrralabs.zagreus` (or your bundle ID prefix)
   - **Bundle Identifier**: Should auto-fill as `com.zebrralabs.zagreus.UpcomingWidget`
   - **Include Configuration Intent**: ❌ **Uncheck this** (we don't need it)
5. Click **Finish**
6. When prompted "Activate 'UpcomingWidget' scheme?", click **Activate**

### Step 3: Replace Generated Files

Xcode creates a template widget. We need to replace it with our custom one:

1. In the Project Navigator (left sidebar), expand the **UpcomingWidget** folder
2. **Delete** these auto-generated files:
   - `UpcomingWidget.swift` (we'll replace it)
   - `UpcomingWidgetBundle.swift` (not needed)
   - Any other `.swift` files in the UpcomingWidget folder

3. **Add our custom files**:
   - Right-click the **UpcomingWidget** folder in Xcode
   - Select **Add Files to "Runner"**
   - Navigate to `ios/UpcomingWidget/`
   - Select **UpcomingWidget.swift**
   - Make sure **"Copy items if needed"** is UNCHECKED
   - Make sure **"UpcomingWidget" target** is CHECKED
   - Click **Add**

### Step 4: Update Info.plist

1. Select **UpcomingWidget** folder → **Info.plist**
2. Replace the contents with our custom one:
   - Right-click `ios/UpcomingWidget/Info.plist` in Finder
   - Copy the file
   - In Xcode, right-click the `UpcomingWidget/Info.plist`
   - Delete it
   - Right-click UpcomingWidget folder → **Add Files to "Runner"**
   - Select our `ios/UpcomingWidget/Info.plist`
   - Add it

### Step 5: Add Entitlements

1. Select the **UpcomingWidget** target in the project navigator
2. Go to **Signing & Capabilities** tab
3. Click **+ Capability**
4. Add **App Groups**
5. Check the box for `group.app.zagreus`
6. Repeat for the **Runner** target if App Groups isn't already there

### Step 6: Update Podfile

Now that the target exists in Xcode, add it to the Podfile:

```ruby
target 'UpcomingWidget' do
  use_frameworks!
  use_modular_headers!
end
```

Add this right after the `Runner` target block (around line 34).

### Step 7: Install Dependencies

```bash
cd ios
pod install
```

### Step 8: Build & Run

1. Select **Runner** scheme (not UpcomingWidget scheme)
2. Select your device or simulator
3. Click **Run** (⌘R)
4. The app should build successfully

## Adding the Widget to Your Home Screen

Once the app is installed:

1. Long-press on your home screen
2. Tap the **+** button in the top-left
3. Search for **"Zagreus"**
4. Select the **Upcoming Movies & Shows** widget
5. Choose a size (Small, Medium, or Large)
6. Tap **Add Widget**

## Widget Features

### Small Widget
- Shows next upcoming item
- Movie/TV icon
- Title, date, and rating

### Medium Widget
- Shows 3 upcoming items
- Compact list view
- Date and rating for each

### Large Widget
- Shows 5 upcoming items
- Includes overview text
- More detail for each item

## Refresh Behavior

- **Auto-refresh**: Widget updates every 4 hours via WidgetKit timeline
- **App launch**: Widget updates when you open the Zagreus app
- **Manual refresh**: You can add a button in the UI to call `UpcomingWidgetService.refreshWidget()`

## Manual Refresh Button (Optional)

To add a manual refresh button to your Discover page, you can call:

```dart
import 'package:zagreus/services/upcoming_widget_service.dart';

// In a button's onPressed:
await UpcomingWidgetService.refreshWidget();
```

This will fetch fresh data from TMDB and update the widget immediately.

## Troubleshooting

### Widget shows "Loading..."
- The widget is using placeholder data
- Check that the app has launched at least once (to initialize the widget)
- Check console logs for TMDB API errors

### Widget doesn't appear in widget gallery
- Make sure you selected the UpcomingWidget target when adding files
- Rebuild the app
- Check that the widget extension is properly code-signed

### App Groups error
- Verify both Runner and UpcomingWidget have App Groups capability
- Verify both are using `group.app.zagreus`
- Check that your provisioning profiles support App Groups

### Build errors
- Run `pod install` in the ios directory
- Clean build folder (⌘⇧K in Xcode)
- Restart Xcode

## What's Next?

The widget is now fully functional! It will:
1. ✅ Fetch upcoming movies/shows from TMDB
2. ✅ Display them in 3 beautiful widget sizes
3. ✅ Auto-refresh every 4 hours
4. ✅ Update when you open the app

Enjoy your new home screen widget! 🎬📺
