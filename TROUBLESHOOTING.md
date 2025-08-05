# Troubleshooting Network Monitor

## Common Build Issues

### "No such module 'ActivityKit'"

**Problem**: Build fails with "No such module 'ActivityKit'" error.

**Solution**: This happens when:
1. **Deployment target too low**: ActivityKit requires iOS 16.1+
   - Check target deployment in Xcode: Project Settings → Deployment Info
   - Ensure iOS Deployment Target is set to 16.1 or higher

2. **Building for macOS**: ActivityKit is iOS-only
   - The code includes `#if os(iOS)` guards to handle this
   - Ensure you're building for iOS target, not macOS

3. **Xcode version**: Ensure you're using Xcode 14.1+ with iOS 16.1+ SDK

**Quick Fix**:
```bash
# In Xcode, select your target and verify:
# - iOS Deployment Target: 16.1+
# - Build for iOS device/simulator (not Mac)
```

### Widget Not Updating

**Problem**: Widget shows stale data or doesn't refresh.

**Solutions**:
1. **App Groups not configured**: 
   - Both main app and widget need `group.dddwj.network-monitor`
   - Go to Signing & Capabilities → App Groups

2. **Main app not running**:
   - Launch the main app to populate shared data
   - Keep app running in background for real-time updates

3. **iOS throttling**:
   - Use app regularly to maintain widget update priority
   - iOS reduces update frequency for unused widgets

### Build Errors After Setup

**Problem**: Project won't build or shows missing files.

**Solutions**:
1. **Clean build folder**: Product → Clean Build Folder (⇧⌘K)
2. **Reset derived data**: 
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```
3. **Check file references**: Ensure all files are properly added to targets

### Code Signing Issues

**Problem**: Code signing failures for widget extension.

**Solutions**:
1. **Development Team**: Set same team for both main app and widget
2. **Bundle IDs**: 
   - Main: `dddwj.network-monitor`
   - Widget: `dddwj.network-monitor.NetworkStatsWidget`
3. **Entitlements**: Both targets need App Groups entitlement

## Runtime Issues

### Network Stats Show Zero

**Problem**: App shows 0.0 MB/s for all network stats.

**Solutions**:
1. **Permissions**: No special permissions needed, but try:
   - Restart the app
   - Check network connection
   - Try on different network interface (WiFi vs cellular)

2. **Network activity**: Generate some network traffic:
   - Browse web, stream video, or download files
   - Stats show actual network usage, not potential speed

### Widget Shows "No Data"

**Problem**: Widget displays placeholder or no data.

**Solutions**:
1. **Launch main app first**: App needs to run to populate shared data
2. **Wait for data**: First launch needs time to collect network stats
3. **Check App Groups**: Verify shared container is accessible

### macOS-Specific Issues

**Problem**: Features not working on macOS.

**Solutions**:
1. **Live Activities**: Not available on macOS (iOS-only feature)
2. **Network monitoring**: May be limited in macOS sandbox
3. **Permissions**: Some network APIs may require additional entitlements

## Debugging Tips

### Enable Debug Logging

Add to NetworkMonitor.swift for debugging:
```swift
private func updateNetworkStats() {
    let stats = getNetworkStats()
    print("Network stats - Download: \(stats.downloadBytes), Upload: \(stats.uploadBytes)")
    // ... rest of method
}
```

### Check Shared Data

Verify widget data sharing:
```swift
// Add to widget provider
print("Shared stats: \(NetworkMonitor.loadStatsFromSharedDefaults())")
```

### Monitor Widget Timeline

Add to widget provider:
```swift
print("Widget timeline requested at: \(Date())")
```

## Getting Help

If issues persist:

1. **Check iOS version**: Ensure device runs iOS 16.1+
2. **Verify Xcode version**: Use Xcode 14.1+
3. **Review console logs**: Look for error messages in Xcode console
4. **Test on device**: Some network APIs work differently on simulator vs device

## Known Issues

1. **Simulator limitations**: Network monitoring may not work properly in iOS Simulator
2. **VPN interference**: VPN connections may affect network statistics accuracy
3. **Widget update delays**: iOS may delay updates during low power mode or heavy system load