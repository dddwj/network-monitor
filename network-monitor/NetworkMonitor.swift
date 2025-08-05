import Foundation
import Network
import SystemConfiguration

class NetworkMonitor: ObservableObject {
    @Published var downloadSpeed: Double = 0.0
    @Published var uploadSpeed: Double = 0.0
    @Published var totalDownloaded: Double = 0.0
    @Published var totalUploaded: Double = 0.0
    @Published var isConnected: Bool = true
    
    private var monitor = NWPathMonitor()
    private var queue = DispatchQueue(label: "NetworkMonitor")
    private var timer: Timer?
    
    private var previousDownloadBytes: UInt64 = 0
    private var previousUploadBytes: UInt64 = 0
    private var previousTimestamp: Date = Date()
    
    init() {
        setupNetworkMonitor()
    }
    
    deinit {
        stopMonitoring()
    }
    
    func startMonitoring() {
        // Start network path monitoring
        monitor.start(queue: queue)
        
        // Start periodic stats update
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateNetworkStats()
        }
        
        // Initial stats update
        updateNetworkStats()
    }
    
    func stopMonitoring() {
        monitor.cancel()
        timer?.invalidate()
        timer = nil
    }
    
    private func setupNetworkMonitor() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
    }
    
    private func updateNetworkStats() {
        let stats = getNetworkStats()
        let currentTime = Date()
        let timeDelta = currentTime.timeIntervalSince(previousTimestamp)
        
        if timeDelta > 0 {
            let downloadDelta = stats.downloadBytes > previousDownloadBytes ? 
                stats.downloadBytes - previousDownloadBytes : 0
            let uploadDelta = stats.uploadBytes > previousUploadBytes ? 
                stats.uploadBytes - previousUploadBytes : 0
            
            DispatchQueue.main.async {
                // Calculate speeds in MB/s
                self.downloadSpeed = Double(downloadDelta) / timeDelta / (1024 * 1024)
                self.uploadSpeed = Double(uploadDelta) / timeDelta / (1024 * 1024)
                
                // Update totals in GB
                self.totalDownloaded = Double(stats.downloadBytes) / (1024 * 1024 * 1024)
                self.totalUploaded = Double(stats.uploadBytes) / (1024 * 1024 * 1024)
            }
        }
        
        previousDownloadBytes = stats.downloadBytes
        previousUploadBytes = stats.uploadBytes
        previousTimestamp = currentTime
        
        // Save stats for widget access
        saveStatsForWidget()
    }
    
    private func getNetworkStats() -> (downloadBytes: UInt64, uploadBytes: UInt64) {
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
                downloadBytes += data.pointee.ifi_ibytes
                uploadBytes += data.pointee.ifi_obytes
            }
        }
        
        return (downloadBytes, uploadBytes)
    }
    
    // Shared data structure for widget communication
    static let sharedUserDefaults = UserDefaults(suiteName: "group.dddwj.network-monitor")
    
    func saveStatsForWidget() {
        guard let sharedDefaults = NetworkMonitor.sharedUserDefaults else { return }
        
        let statsData: [String: Any] = [
            "downloadSpeed": downloadSpeed,
            "uploadSpeed": uploadSpeed,
            "totalDownloaded": totalDownloaded,
            "totalUploaded": totalUploaded,
            "isConnected": isConnected,
            "lastUpdated": Date()
        ]
        
        sharedDefaults.set(statsData, forKey: "networkStats")
    }
    
    static func loadStatsFromSharedDefaults() -> NetworkStats? {
        guard let sharedDefaults = sharedUserDefaults,
              let statsData = sharedDefaults.dictionary(forKey: "networkStats") else {
            return nil
        }
        
        return NetworkStats(
            downloadSpeed: statsData["downloadSpeed"] as? Double ?? 0.0,
            uploadSpeed: statsData["uploadSpeed"] as? Double ?? 0.0,
            totalDownloaded: statsData["totalDownloaded"] as? Double ?? 0.0,
            totalUploaded: statsData["totalUploaded"] as? Double ?? 0.0,
            isConnected: statsData["isConnected"] as? Bool ?? false,
            lastUpdated: statsData["lastUpdated"] as? Date ?? Date()
        )
    }
}

struct NetworkStats {
    let downloadSpeed: Double
    let uploadSpeed: Double
    let totalDownloaded: Double
    let totalUploaded: Double
    let isConnected: Bool
    let lastUpdated: Date
}