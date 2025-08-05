# Network Monitor Setup Guide

## Quick Start

1. **Open the Project**
   ```bash
   cd /Users/wdong01/codes/network-monitor
   open network-monitor.xcodeproj
   ```

2. **Configure App Groups** (Required for widget data sharing)
   - Select the `network-monitor` target
   - Go to "Signing & Capabilities"
   - Click "+" and add "App Groups"
   - Enable `group.dddwj.network-monitor`
   - Repeat for `NetworkStatsWidget` target

3. **Set Development Team**
   - In both targets, set your Apple Developer Team
   - Ensure bundle identifiers are unique to your team

4. **Build and Run**
   - Select your device/simulator
   - Build and run (⌘+R)

## Adding the Widget

### iOS
1. Long press on the home screen
2. Tap the "+" button in the top-left corner
3. Search for "Network Stats"
4. Choose widget size (Small, Medium, or Large)
5. Tap "Add Widget"

### macOS
1. Right-click on the desktop
2. Select "Edit Widgets"
3. Click "+" to add a new widget
4. Find "Network Stats" in the list
5. Choose size and add to desktop

## Widget Features by Size

### Small Widget
- Download/Upload speeds
- Connection status indicator
- Minimal, compact view

### Medium Widget  
- Current speeds with labels
- Total data usage
- Connection status

### Large Widget
- Full statistics dashboard
- All network metrics
- Real-time timestamp
- Color-coded statistics

## Technical Details

### Real-time Updates
- Main app: Updates every 1 second
- Widget: Requests updates every 1 second (iOS may throttle)
- Uses shared UserDefaults for data communication

### Network Monitoring
- Monitors all active network interfaces
- Excludes loopback (localhost) traffic
- Tracks bytes sent/received via system APIs
- Calculates speeds based on time deltas

### Data Sharing
- App Groups: `group.com.networkmonitor.app`
- Shared UserDefaults for widget data
- Background-safe data synchronization

## Troubleshooting

### Widget Shows "No Data"
- Ensure the main app has been launched recently
- Check App Groups configuration
- Verify bundle identifiers match

### Permission Issues
- Network monitoring uses system APIs
- No special permissions required
- Sandboxed for security

### Build Errors
- Check development team settings
- Verify unique bundle identifiers
- Ensure proper App Groups configuration

## Performance Notes

iOS manages widget update frequency based on:
- App usage patterns
- Battery level
- System load
- Time of day

For best results, use the app regularly to maintain high widget update priority.