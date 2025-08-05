# Network Monitor

A SwiftUI application for iOS and macOS that monitors real-time network statistics including upload and download speeds. The app includes a home screen widget that displays network stats and refreshes frequently.

## Features

- 📊 Real-time network monitoring (upload/download speeds)
- 📱 Native iOS and macOS support with SwiftUI
- 🔧 Home screen widget in multiple sizes (Small, Medium, Large)
- 🔄 Updates every second for real-time data
- 📈 Total data usage tracking
- 🎯 Dynamic Island support (iPhone 14 Pro and later)
- 🌐 Network connectivity status indicator

## Requirements

- iOS 16.0+ / macOS 13.0+
- Xcode 15.0+
- Swift 5.9+

## Installation

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd network-monitor
   ```

2. Open `NetworkMonitor.xcodeproj` in Xcode

3. Set up App Groups:
   - In the Capabilities tab for both the main app and widget extension targets
   - Enable "App Groups"
   - Add group: `group.com.networkmonitor.app`

4. Configure your development team and bundle identifiers:
   - Main app: `com.networkmonitor.app` 
   - Widget extension: `com.networkmonitor.app.NetworkStatsWidgetExtension`

5. Build and run the project

## Usage

### Main App
- Launch the app to see detailed network statistics
- The app displays current upload/download speeds and total data usage
- Network connectivity status is shown with a colored indicator

### Widget
- Long press on your home screen and tap the "+" button
- Search for "Network Stats" 
- Choose from Small, Medium, or Large widget sizes
- Add to your home screen

### Widget Sizes

- **Small Widget**: Shows basic upload/download speeds with connectivity status
- **Medium Widget**: Displays speeds with total data usage
- **Large Widget**: Complete view with all statistics and timestamp

## Architecture

### Main Components

1. **NetworkMonitor.swift**: Core network monitoring service using system APIs
2. **ContentView.swift**: Main app interface displaying network statistics
3. **NetworkStatsWidget.swift**: Widget implementation with multiple size variants
4. **NetworkStatsWidgetLiveActivity.swift**: Dynamic Island and Live Activities support

### Data Sharing
The app uses App Groups to share network statistics between the main app and widget through shared UserDefaults.

### Network Monitoring
Network statistics are gathered using:
- `getifaddrs()` system call for interface statistics
- Network.framework for connectivity monitoring
- Timer-based periodic updates

## Limitations

1. **Widget Refresh Rate**: While the code requests 1-second updates, iOS may throttle widget updates based on:
   - App usage patterns
   - Device battery level
   - Time of day
   - System resources

2. **Background Monitoring**: Network monitoring requires the app to be running. The widget shows cached data when the app is not active.

3. **Permissions**: The app reads system network interface statistics and doesn't require special permissions, but some detailed metrics may be limited in sandboxed environments.

## Customization

### Colors and Styling
Modify the color schemes in the SwiftUI views:
- Download: Blue (`.blue`)
- Upload: Green (`.green`) 
- Total Downloaded: Purple (`.purple`)
- Total Uploaded: Orange (`.orange`)

### Update Frequency
Change the timer interval in `NetworkMonitor.swift`:
```swift
timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
    self.updateNetworkStats()
}
```

### Widget Timeline
Modify refresh frequency in `NetworkStatsWidget.swift`:
```swift
let nextUpdateDate = Calendar.current.date(byAdding: .second, value: 1, to: currentDate)!
```

## Troubleshooting

### Widget Not Updating
1. Ensure App Groups are properly configured
2. Check that both targets have the same App Group identifier
3. Verify the main app has run recently to populate shared data
4. Try removing and re-adding the widget

### Network Stats Showing Zero
1. Check network connectivity
2. Ensure the app has been granted necessary permissions
3. Try restarting the app
4. Verify network interfaces are active

### Build Errors
1. Ensure proper development team and bundle identifiers are set
2. Check that all targets have matching deployment targets
3. Verify WidgetKit framework is properly linked

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test on both iOS and macOS
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Uses Apple's Network.framework for connectivity monitoring
- Built with SwiftUI and WidgetKit
- Network interface statistics via BSD socket APIs