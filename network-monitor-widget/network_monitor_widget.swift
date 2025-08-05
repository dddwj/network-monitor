import WidgetKit
import SwiftUI
import AppIntents

// App Intent for widget configuration
struct NetworkStatsConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Network Stats Configuration" }
    static var description: IntentDescription { "Configure network statistics display" }

    @Parameter(title: "Show Total Data", default: true)
    var showTotalData: Bool
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}

// Timeline Provider
struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: NetworkStatsConfigurationIntent())
    }

    func snapshot(for configuration: NetworkStatsConfigurationIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: NetworkStatsConfigurationIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        // Generate timeline with network stats
        let currentDate = Date()
        for minuteOffset in 0 ..< 60 { // Update every minute for 1 hour
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }
}

// Entry structure
struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: NetworkStatsConfigurationIntent
    
    // Network stats (will be populated by main app)
    var downloadSpeed: Double = 0.0
    var uploadSpeed: Double = 0.0
    var totalDownloaded: Double = 0.0
    var totalUploaded: Double = 0.0
    var isConnected: Bool = true
}

// Small Widget View
struct SmallWidgetView: View {
    let entry: SimpleEntry
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "wifi")
                    .foregroundColor(entry.isConnected ? .green : .red)
                
                Text("Network")
                    .font(.caption)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            VStack(spacing: 4) {
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

// Medium Widget View
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
                    Text("Download")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: "arrow.down")
                            .foregroundColor(.blue)
                        Text("\(String(format: "%.1f", entry.downloadSpeed)) MB/s")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Upload")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: "arrow.up")
                            .foregroundColor(.green)
                        Text("\(String(format: "%.1f", entry.uploadSpeed)) MB/s")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                }
            }
            
            if entry.configuration.showTotalData {
                HStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total ↓")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("\(String(format: "%.1f", entry.totalDownloaded)) MB")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total ↑")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("\(String(format: "%.1f", entry.totalUploaded)) MB")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                }
            }
        }
        .padding(.all, 16)
        .background(Color(.systemBackground))
    }
}

// Large Widget View
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
            
            VStack(spacing: 16) {
                // Speed Section
                VStack(spacing: 12) {
                    Text("Current Speed")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 20) {
                        NetworkStatCard(
                            title: "Download",
                            value: "\(String(format: "%.1f", entry.downloadSpeed)) MB/s",
                            icon: "arrow.down",
                            color: .blue
                        )
                        
                        NetworkStatCard(
                            title: "Upload",
                            value: "\(String(format: "%.1f", entry.uploadSpeed)) MB/s",
                            icon: "arrow.up",
                            color: .green
                        )
                    }
                }
                
                // Total Data Section
                if entry.configuration.showTotalData {
                    VStack(spacing: 12) {
                        Text("Total Data")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 20) {
                            NetworkStatCard(
                                title: "Downloaded",
                                value: "\(String(format: "%.1f", entry.totalDownloaded)) MB",
                                icon: "arrow.down.circle",
                                color: .blue
                            )
                            
                            NetworkStatCard(
                                title: "Uploaded",
                                value: "\(String(format: "%.1f", entry.totalUploaded)) MB",
                                icon: "arrow.up.circle",
                                color: .green
                            )
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding(.all, 20)
        .background(Color(.systemBackground))
    }
}

// Network Stat Card Component
struct NetworkStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// Main Widget View
struct NetworkStatsWidgetView: View {
    let entry: SimpleEntry
    
    var body: some View {
        GeometryReader { geometry in
            let isSmall = geometry.size.width < 200
            let isMedium = geometry.size.width < 400
            
            if isSmall {
                SmallWidgetView(entry: entry)
            } else if isMedium {
                MediumWidgetView(entry: entry)
            } else {
                LargeWidgetView(entry: entry)
            }
        }
    }
}

// Main Widget Configuration
struct NetworkStatsWidget: Widget {
    let kind: String = "NetworkStatsWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: NetworkStatsConfigurationIntent.self, provider: Provider()) { entry in
            NetworkStatsWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Network Stats")
        .description("Monitor your network upload and download speeds")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// Preview
#Preview(as: .systemSmall) {
    NetworkStatsWidget()
} timeline: {
    SimpleEntry(date: .now, configuration: NetworkStatsConfigurationIntent())
}

#Preview(as: .systemMedium) {
    NetworkStatsWidget()
} timeline: {
    SimpleEntry(date: .now, configuration: NetworkStatsConfigurationIntent())
}

#Preview(as: .systemLarge) {
    NetworkStatsWidget()
} timeline: {
    SimpleEntry(date: .now, configuration: NetworkStatsConfigurationIntent())
}
