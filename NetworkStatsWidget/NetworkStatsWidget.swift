import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            downloadSpeed: 2.5,
            uploadSpeed: 1.2,
            totalDownloaded: 45.6,
            totalUploaded: 12.3,
            isConnected: true
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(
            date: Date(),
            downloadSpeed: 2.5,
            uploadSpeed: 1.2,
            totalDownloaded: 45.6,
            totalUploaded: 12.3,
            isConnected: true
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // Get current network stats
        let stats = getCurrentNetworkStats()
        
        let currentDate = Date()
        let entry = SimpleEntry(
            date: currentDate,
            downloadSpeed: stats.downloadSpeed,
            uploadSpeed: stats.uploadSpeed,
            totalDownloaded: stats.totalDownloaded,
            totalUploaded: stats.totalUploaded,
            isConnected: stats.isConnected
        )
        
        // Create timeline with 1-second updates
        let nextUpdateDate = Calendar.current.date(byAdding: .second, value: 1, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
        
        completion(timeline)
    }
    
    private func getCurrentNetworkStats() -> SimpleNetworkStats {
        // Try to get stats from shared UserDefaults first (if main app is running)
        if let sharedDefaults = UserDefaults(suiteName: "group.dddwj.network-monitor"),
           let statsData = sharedDefaults.dictionary(forKey: "networkStats") {
            return SimpleNetworkStats(
                downloadSpeed: statsData["downloadSpeed"] as? Double ?? 0.0,
                uploadSpeed: statsData["uploadSpeed"] as? Double ?? 0.0,
                totalDownloaded: statsData["totalDownloaded"] as? Double ?? 0.0,
                totalUploaded: statsData["totalUploaded"] as? Double ?? 0.0,
                isConnected: statsData["isConnected"] as? Bool ?? false,
                lastUpdated: statsData["lastUpdated"] as? Date ?? Date()
            )
        }
        
        // Fallback to direct measurement
        return measureNetworkStats()
    }
    
    private func measureNetworkStats() -> SimpleNetworkStats {
        let stats = getNetworkInterfaceStats()
        return SimpleNetworkStats(
            downloadSpeed: 0.0, // Speed calculation requires time delta
            uploadSpeed: 0.0,
            totalDownloaded: Double(stats.downloadBytes) / (1024 * 1024 * 1024),
            totalUploaded: Double(stats.uploadBytes) / (1024 * 1024 * 1024),
            isConnected: stats.downloadBytes > 0 || stats.uploadBytes > 0,
            lastUpdated: Date()
        )
    }
    
    private func getNetworkInterfaceStats() -> (downloadBytes: UInt64, uploadBytes: UInt64) {
        var downloadBytes: UInt64 = 0
        var uploadBytes: UInt64 = 0
        
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        
        guard getifaddrs(&ifaddr) == 0 else {
            return (0, 0)
        }
        
        defer {
            freeifaddrs(ifaddr)
        }
        
        var ptr = ifaddr
        while ptr != nil {
            defer {
                ptr = ptr?.pointee.ifa_next
            }
            
            guard let interface = ptr?.pointee else { continue }
            
            let name = String(cString: interface.ifa_name)
            
            // Skip loopback and non-active interfaces
            guard !name.hasPrefix("lo") && 
                  (interface.ifa_flags & UInt32(IFF_UP)) != 0 &&
                  (interface.ifa_flags & UInt32(IFF_RUNNING)) != 0 else {
                continue
            }
            
            if interface.ifa_addr?.pointee.sa_family == UInt8(AF_LINK) {
                let data = unsafeBitCast(interface.ifa_data, to: UnsafeMutablePointer<if_data>.self)
                downloadBytes += UInt64(data.pointee.ifi_ibytes)
                uploadBytes += UInt64(data.pointee.ifi_obytes)
            }
        }
        
        return (downloadBytes, uploadBytes)
    }
}

// Simple version of NetworkStats for widget use
struct SimpleNetworkStats {
    let downloadSpeed: Double
    let uploadSpeed: Double
    let totalDownloaded: Double
    let totalUploaded: Double
    let isConnected: Bool
    let lastUpdated: Date
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let downloadSpeed: Double
    let uploadSpeed: Double
    let totalDownloaded: Double
    let totalUploaded: Double
    let isConnected: Bool
}

struct NetworkStatsWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

struct SmallWidgetView: View {
    let entry: SimpleEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "wifi")
                    .foregroundColor(entry.isConnected ? .green : .red)
                
                Spacer()
                
                Text("Network")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "arrow.down")
                        .foregroundColor(.blue)
                        .font(.caption2)
                    
                    Text("\(String(format: "%.1f", entry.downloadSpeed)) MB/s")
                        .font(.caption2)
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Image(systemName: "arrow.up")
                        .foregroundColor(.green)
                        .font(.caption2)
                    
                    Text("\(String(format: "%.1f", entry.uploadSpeed)) MB/s")
                        .font(.caption2)
                        .fontWeight(.semibold)
                }
            }
            
            Spacer()
        }
        .padding(.all, 12)
        .background(Color(.systemBackground))
    }
}

struct MediumWidgetView: View {
    let entry: SimpleEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "wifi")
                    .foregroundColor(entry.isConnected ? .green : .red)
                
                Text("Network Monitor")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "arrow.down.circle.fill")
                            .foregroundColor(.blue)
                        
                        Text("Download")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("\(String(format: "%.2f", entry.downloadSpeed)) MB/s")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text("\(String(format: "%.1f", entry.totalDownloaded)) GB total")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(.green)
                        
                        Text("Upload")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("\(String(format: "%.2f", entry.uploadSpeed)) MB/s")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text("\(String(format: "%.1f", entry.totalUploaded)) GB total")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding(.all, 16)
        .background(Color(.systemBackground))
    }
}

struct LargeWidgetView: View {
    let entry: SimpleEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "wifi")
                    .foregroundColor(entry.isConnected ? .green : .red)
                    .font(.title2)
                
                Text("Network Monitor")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text(entry.date, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                NetworkStatCard(
                    title: "Download Speed",
                    value: entry.downloadSpeed,
                    unit: "MB/s",
                    icon: "arrow.down.circle.fill",
                    color: .blue
                )
                
                NetworkStatCard(
                    title: "Upload Speed",
                    value: entry.uploadSpeed,
                    unit: "MB/s",
                    icon: "arrow.up.circle.fill",
                    color: .green
                )
                
                NetworkStatCard(
                    title: "Downloaded",
                    value: entry.totalDownloaded,
                    unit: "GB",
                    icon: "icloud.and.arrow.down.fill",
                    color: .purple
                )
                
                NetworkStatCard(
                    title: "Uploaded",
                    value: entry.totalUploaded,
                    unit: "GB",
                    icon: "icloud.and.arrow.up.fill",
                    color: .orange
                )
            }
            
            Spacer()
        }
        .padding(.all, 16)
        .background(Color(.systemBackground))
    }
}

struct NetworkStatCard: View {
    let title: String
    let value: Double
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                
                Spacer()
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(String(format: "%.2f", value))
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text(unit)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct NetworkStatsWidget: Widget {
    let kind: String = "NetworkStatsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                NetworkStatsWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                NetworkStatsWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Network Stats")
        .description("Monitor your network upload and download speeds in real-time.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// Widget previews for iOS 16.0 compatibility
struct NetworkStatsWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NetworkStatsWidgetEntryView(entry: SimpleEntry(
                date: Date(),
                downloadSpeed: 2.5,
                uploadSpeed: 1.2,
                totalDownloaded: 45.6,
                totalUploaded: 12.3,
                isConnected: true
            ))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            .previewDisplayName("Small")
            
            NetworkStatsWidgetEntryView(entry: SimpleEntry(
                date: Date(),
                downloadSpeed: 2.5,
                uploadSpeed: 1.2,
                totalDownloaded: 45.6,
                totalUploaded: 12.3,
                isConnected: true
            ))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .previewDisplayName("Medium")
            
            NetworkStatsWidgetEntryView(entry: SimpleEntry(
                date: Date(),
                downloadSpeed: 2.5,
                uploadSpeed: 1.2,
                totalDownloaded: 45.6,
                totalUploaded: 12.3,
                isConnected: true
            ))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
            .previewDisplayName("Large")
        }
    }
}
