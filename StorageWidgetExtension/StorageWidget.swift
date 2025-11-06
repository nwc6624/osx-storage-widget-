import WidgetKit
import SwiftUI

struct StorageWidget: Widget {
    let kind: String = "StorageWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StorageTimelineProvider()) { entry in
            StorageWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Storage Widget")
        .description("Displays your disk storage information.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct StorageEntry: TimelineEntry {
    let date: Date
    let drives: [DriveInfo]
}

struct StorageTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> StorageEntry {
        StorageEntry(date: Date(), drives: DriveInfo.placeholderDrives)
    }

    func getSnapshot(in context: Context, completion: @escaping (StorageEntry) -> ()) {
        let entry = StorageEntry(date: Date(), drives: DriveInfo.getDrives())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StorageEntry>) -> ()) {
        let entry = StorageEntry(date: Date(), drives: DriveInfo.getDrives())
        // Refresh every 30 minutes
        let timeline = Timeline(entries: [entry], policy: .after(Calendar.current.date(byAdding: .minute, value: 30, to: Date())!))
        completion(timeline)
    }
}

struct StorageWidgetEntryView: View {
    var entry: StorageEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        // Display multiple drives horizontally, similar to battery widget
        MultiDriveView(drives: entry.drives)
    }
}

struct MultiDriveView: View {
    let drives: [DriveInfo]
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(Array(drives.enumerated()), id: \.offset) { index, drive in
                RingView(progress: drive.usedPercent, isInternal: drive.isInternal)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct StorageWidget_Previews: PreviewProvider {
    static var previews: some View {
        StorageWidgetEntryView(entry: StorageEntry(date: Date(), drives: DriveInfo.placeholderDrives))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        
        StorageWidgetEntryView(entry: StorageEntry(date: Date(), drives: DriveInfo.placeholderDrives))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        
        StorageWidgetEntryView(entry: StorageEntry(date: Date(), drives: DriveInfo.placeholderDrives))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}

