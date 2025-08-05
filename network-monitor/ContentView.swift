import SwiftUI

struct ContentView: View {
    @StateObject private var networkMonitor = NetworkMonitor()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // Header
                Text("Network Monitor")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Network Stats Cards
                VStack(spacing: 20) {
                    NetworkStatCard(
                        title: "Download Speed",
                        value: networkMonitor.downloadSpeed,
                        unit: "MB/s",
                        color: .blue,
                        icon: "arrow.down.circle.fill"
                    )
                    
                    NetworkStatCard(
                        title: "Upload Speed",
                        value: networkMonitor.uploadSpeed,
                        unit: "MB/s",
                        color: .green,
                        icon: "arrow.up.circle.fill"
                    )
                    
                    NetworkStatCard(
                        title: "Total Downloaded",
                        value: networkMonitor.totalDownloaded,
                        unit: "GB",
                        color: .purple,
                        icon: "icloud.and.arrow.down.fill"
                    )
                    
                    NetworkStatCard(
                        title: "Total Uploaded",
                        value: networkMonitor.totalUploaded,
                        unit: "GB",
                        color: .orange,
                        icon: "icloud.and.arrow.up.fill"
                    )
                }
                
                Spacer()
                
                // Status
                HStack {
                    Circle()
                        .fill(networkMonitor.isConnected ? .green : .red)
                        .frame(width: 12, height: 12)
                    
                    Text(networkMonitor.isConnected ? "Connected" : "Disconnected")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .onAppear {
                networkMonitor.startMonitoring()
            }
            .onDisappear {
                networkMonitor.stopMonitoring()
            }
        }
    }
}

struct NetworkStatCard: View {
    let title: String
    let value: Double
    let unit: String
    let color: Color
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(String(format: "%.2f", value))
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    ContentView()
}