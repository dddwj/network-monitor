import WidgetKit
import SwiftUI

@main
struct NetworkStatsWidgetBundle: WidgetBundle {
    var body: some Widget {
        NetworkStatsWidget()
        NetworkStatsWidgetLiveActivity()
    }
}