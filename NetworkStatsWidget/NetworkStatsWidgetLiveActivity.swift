import WidgetKit
import SwiftUI

// ActivityKit only available on iOS 16.1+
#if canImport(ActivityKit)
import ActivityKit

@available(iOS 16.1, *)
struct NetworkStatsWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var downloadSpeed: Double
        var uploadSpeed: Double
        var isConnected: Bool
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

@available(iOS 16.1, *)
struct NetworkStatsWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: NetworkStatsWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "wifi")
                        .foregroundColor(context.state.isConnected ? .green : .red)
                    
                    Text("Network Monitor")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                }
                
                HStack(spacing: 20) {
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "arrow.down")
                                .foregroundColor(.blue)
                                .font(.caption)
                            
                            Text("Download")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Text("\(String(format: "%.2f", context.state.downloadSpeed)) MB/s")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "arrow.up")
                                .foregroundColor(.green)
                                .font(.caption)
                            
                            Text("Upload")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Text("\(String(format: "%.2f", context.state.uploadSpeed)) MB/s")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    
                    Spacer()
                }
            }
            .padding()
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    HStack {
                        Image(systemName: "arrow.down")
                            .foregroundColor(.blue)
                        
                        Text("\(String(format: "%.1f", context.state.downloadSpeed))")
                            .fontWeight(.semibold)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    HStack {
                        Image(systemName: "arrow.up")
                            .foregroundColor(.green)
                        
                        Text("\(String(format: "%.1f", context.state.uploadSpeed))")
                            .fontWeight(.semibold)
                    }
                }
                DynamicIslandExpandedRegion(.center) {
                    Text("Network Monitor")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Image(systemName: "wifi")
                            .foregroundColor(context.state.isConnected ? .green : .red)
                        
                        Text(context.state.isConnected ? "Connected" : "Disconnected")
                            .font(.caption2)
                    }
                }
            } compactLeading: {
                Image(systemName: "wifi")
                    .foregroundColor(context.state.isConnected ? .green : .red)
            } compactTrailing: {
                Text("\(String(format: "%.1f", context.state.downloadSpeed))↓")
                    .font(.caption2)
                    .fontWeight(.semibold)
            } minimal: {
                Image(systemName: "wifi")
                    .foregroundColor(context.state.isConnected ? .green : .red)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

@available(iOS 16.1, *)
extension NetworkStatsWidgetAttributes {
    fileprivate static var preview: NetworkStatsWidgetAttributes {
        NetworkStatsWidgetAttributes(name: "Network Monitor")
    }
}

@available(iOS 16.1, *)
extension NetworkStatsWidgetAttributes.ContentState {
    fileprivate static var sampleData: NetworkStatsWidgetAttributes.ContentState {
        NetworkStatsWidgetAttributes.ContentState(
            downloadSpeed: 2.5,
            uploadSpeed: 1.2,
            isConnected: true
        )
     }
}

// Live Activity previews for iOS 16.1+
@available(iOS 16.1, *)
struct NetworkStatsWidgetLiveActivity_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 17.0, *) {
            // Use new preview syntax on iOS 17+
            Color.clear
                .previewDisplayName("Live Activity Preview")
        } else {
            // Fallback for iOS 16.1
            Text("Live Activity Preview")
                .previewDisplayName("Live Activity")
        }
    }
}

#endif
