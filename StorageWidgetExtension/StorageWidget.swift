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
    let driveInfo: DriveInfo
}

struct StorageTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> StorageEntry {
        StorageEntry(date: Date(), driveInfo: DriveInfo.placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (StorageEntry) -> ()) {
        let entry = StorageEntry(date: Date(), driveInfo: DriveInfo.current)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StorageEntry>) -> ()) {
        let entry = StorageEntry(date: Date(), driveInfo: DriveInfo.current)
        let timeline = Timeline(entries: [entry], policy: .after(Calendar.current.date(byAdding: .minute, value: 15, to: Date())!))
        completion(timeline)
    }
}

struct StorageWidgetEntryView: View {
    var entry: StorageEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallStorageView(driveInfo: entry.driveInfo)
        case .systemMedium:
            MediumStorageView(driveInfo: entry.driveInfo)
        case .systemLarge:
            LargeStorageView(driveInfo: entry.driveInfo)
        default:
            SmallStorageView(driveInfo: entry.driveInfo)
        }
    }
}

struct SmallStorageView: View {
    let driveInfo: DriveInfo
    
    private var isInternal: Bool {
        driveInfo.name.contains("Mac") || driveInfo.name.contains("SSD") || driveInfo.name.contains("Internal")
    }
    
    var body: some View {
        VStack(spacing: 8) {
            RingView(progress: driveInfo.usedPercent, isInternal: isInternal)
                .frame(width: 80, height: 100)
            
            Text(driveInfo.name)
                .font(.headline)
                .foregroundColor(.white)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct MediumStorageView: View {
    let driveInfo: DriveInfo
    
    private var isInternal: Bool {
        driveInfo.name.contains("Mac") || driveInfo.name.contains("SSD") || driveInfo.name.contains("Internal")
    }
    
    var body: some View {
        HStack(spacing: 16) {
            RingView(progress: driveInfo.usedPercent, isInternal: isInternal)
                .frame(width: 120, height: 150)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(driveInfo.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Used: \(driveInfo.formattedUsed)")
                    .font(.body)
                    .foregroundColor(.white)
                
                Text("Free: \(driveInfo.formattedFree)")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.7))
                
                Text("Total: \(driveInfo.formattedTotal)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .padding()
    }
}

struct LargeStorageView: View {
    let driveInfo: DriveInfo
    
    private var isInternal: Bool {
        driveInfo.name.contains("Mac") || driveInfo.name.contains("SSD") || driveInfo.name.contains("Internal")
    }
    
    var body: some View {
        VStack(spacing: 16) {
            RingView(progress: driveInfo.usedPercent, isInternal: isInternal)
                .frame(width: 150, height: 180)
            
            Text(driveInfo.name)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Used:")
                        .font(.body)
                        .foregroundColor(.white)
                    Spacer()
                    Text(driveInfo.formattedUsed)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                
                HStack {
                    Text("Free:")
                        .font(.body)
                        .foregroundColor(.white)
                    Spacer()
                    Text(driveInfo.formattedFree)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                HStack {
                    Text("Total:")
                        .font(.body)
                        .foregroundColor(.white)
                    Spacer()
                    Text(driveInfo.formattedTotal)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
}

struct StorageWidget_Previews: PreviewProvider {
    static var previews: some View {
        StorageWidgetEntryView(entry: StorageEntry(date: Date(), driveInfo: DriveInfo.placeholder))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        
        StorageWidgetEntryView(entry: StorageEntry(date: Date(), driveInfo: DriveInfo.placeholder))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        
        StorageWidgetEntryView(entry: StorageEntry(date: Date(), driveInfo: DriveInfo.placeholder))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}

