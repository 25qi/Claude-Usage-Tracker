import Foundation

/// Helper for consistent formatting throughout the app
enum FormatterHelper {
    /// Formats time until a reset (e.g., "in 2 hours", "in 3 days")
    static func timeUntilReset(from resetDate: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.dateTimeStyle = .named
        return formatter.localizedString(for: resetDate, relativeTo: Date())
    }

    /// Formats an absolute reset date-time for notification text (e.g., "Today, 3:45 PM")
    static func resetDateTime(from resetDate: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        // 讓今天/明天顯示為相對日期,其餘顯示完整日期
        formatter.doesRelativeDateFormatting = true
        return formatter.string(from: resetDate)
    }
}
