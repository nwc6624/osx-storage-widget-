import Foundation

struct DriveInfo {
    let name: String
    let total: Int64
    let available: Int64
    
    var usedPercent: Double {
        guard total > 0 else { return 0 }
        let used = total - available
        return Double(used) / Double(total)
    }
    
    var used: Int64 {
        total - available
    }
    
    // Helper computed properties for backward compatibility with existing widget code
    var totalBytes: Int64 { total }
    var freeBytes: Int64 { available }
    var usedBytes: Int64 { used }
    var usedPercentage: Double { usedPercent }
    
    var formattedTotal: String {
        ByteCountFormatter.string(fromByteCount: total, countStyle: .file)
    }
    
    var formattedUsed: String {
        ByteCountFormatter.string(fromByteCount: used, countStyle: .file)
    }
    
    var formattedFree: String {
        ByteCountFormatter.string(fromByteCount: available, countStyle: .file)
    }
    
    /// Returns an array of all mounted drives (internal + external)
    static func getAllMountedDrives() -> [DriveInfo] {
        let fileManager = FileManager.default
        var drives: [DriveInfo] = []
        
        // Get all mounted volume URLs
        guard let volumeURLs = fileManager.mountedVolumeURLs(
            includingResourceValuesForKeys: [
                .volumeAvailableCapacityForImportantUsageKey,
                .volumeTotalCapacityKey,
                .volumeNameKey,
                .volumeIsRemovableKey,
                .volumeIsInternalKey
            ],
            options: [.skipHiddenVolumes]
        ) else {
            return []
        }
        
        var internalDriveCount = 0
        var externalDriveCount = 0
        
        for volumeURL in volumeURLs {
            do {
                let resourceValues = try volumeURL.resourceValues(forKeys: [
                    .volumeAvailableCapacityForImportantUsageKey,
                    .volumeTotalCapacityKey,
                    .volumeNameKey,
                    .volumeIsRemovableKey,
                    .volumeIsInternalKey
                ])
                
                guard let totalCapacity = resourceValues.volumeTotalCapacityKey,
                      let availableCapacity = resourceValues.volumeAvailableCapacityForImportantUsageKey else {
                    continue
                }
                
                let isInternal = resourceValues.volumeIsInternalKey ?? false
                let isRemovable = resourceValues.volumeIsRemovableKey ?? false
                let volumeName = resourceValues.volumeNameKey
                
                // Generate a simple name
                let name: String
                if let volumeName = volumeName, !volumeName.isEmpty {
                    name = volumeName
                } else if isInternal {
                    internalDriveCount += 1
                    name = internalDriveCount == 1 ? "Mac SSD" : "Internal \(internalDriveCount)"
                } else if isRemovable {
                    externalDriveCount += 1
                    name = externalDriveCount == 1 ? "External 1" : "External \(externalDriveCount)"
                } else {
                    internalDriveCount += 1
                    name = internalDriveCount == 1 ? "Mac SSD" : "Internal \(internalDriveCount)"
                }
                
                let driveInfo = DriveInfo(
                    name: name,
                    total: Int64(totalCapacity),
                    available: Int64(availableCapacity)
                )
                
                drives.append(driveInfo)
            } catch {
                // Skip volumes where we can't read resource values
                continue
            }
        }
        
        return drives
    }
    
    // Legacy support for existing widget code
    static var current: DriveInfo {
        let drives = getAllMountedDrives()
        // Return the first internal drive, or first drive if no internal drive found
        return drives.first { drive in
            // Try to identify internal drive (usually the first one or the one with "Mac" in name)
            drive.name.contains("Mac") || drive.name.contains("SSD")
        } ?? drives.first ?? placeholder
    }
    
    /// Returns up to 4 drives for widget display
    static func getDrives() -> [DriveInfo] {
        let allDrives = getAllMountedDrives()
        return Array(allDrives.prefix(4))
    }
    
    /// Determines if a drive is internal based on its name
    var isInternal: Bool {
        name.contains("Mac") || name.contains("SSD") || name.contains("Internal")
    }
    
    static var placeholder: DriveInfo {
        DriveInfo(
            name: "Mac SSD",
            total: 1_000_000_000_000, // 1 TB
            available: 300_000_000_000 // 300 GB
        )
    }
    
    static var placeholderDrives: [DriveInfo] {
        [
            DriveInfo(name: "Mac SSD", total: 1_000_000_000_000, available: 300_000_000_000),
            DriveInfo(name: "External 1", total: 500_000_000_000, available: 200_000_000_000)
        ]
    }
}

