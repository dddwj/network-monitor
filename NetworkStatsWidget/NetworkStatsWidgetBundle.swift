import WidgetKit
import SwiftUI

@main
struct NetworkStatsWidgetBundle: WidgetBundle {
    var body: some Widget {
        NetworkStatsWidget()
        // Live Activity requires iOS 16.1+ and ActivityKit
        #if canImport(ActivityKit)
        if #available(iOS 16.1, *) {
            NetworkStatsWidgetLiveActivity()
        }
        #endif
    }
}