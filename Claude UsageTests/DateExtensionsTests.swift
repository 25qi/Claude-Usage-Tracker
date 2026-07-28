import XCTest
@testable import Claude_Usage

final class DateExtensionsTests: XCTestCase {

    // MARK: - Next Monday Tests

    func testNextMondayFromSunday() {
        // Sunday Dec 15, 2024 at 10:00 AM
        let sunday = createDate(year: 2024, month: 12, day: 15, hour: 10)
        let nextMonday = sunday.nextMonday1259pm()

        let calendar = Calendar.current
        XCTAssertEqual(calendar.component(.weekday, from: nextMonday), 2) // Monday
        XCTAssertEqual(calendar.component(.hour, from: nextMonday), 12)
        XCTAssertEqual(calendar.component(.minute, from: nextMonday), 59)
    }

    func testNextMondayFromMonday() {
        // Monday Dec 16, 2024 at 10:00 AM - should go to NEXT Monday
        let monday = createDate(year: 2024, month: 12, day: 16, hour: 10)
        let nextMonday = monday.nextMonday1259pm()

        let calendar = Calendar.current
        XCTAssertEqual(calendar.component(.weekday, from: nextMonday), 2) // Monday
        XCTAssertEqual(calendar.component(.day, from: nextMonday), 23) // Dec 23
    }

    func testNextMondayFromWednesday() {
        // Wednesday Dec 18, 2024
        let wednesday = createDate(year: 2024, month: 12, day: 18, hour: 10)
        let nextMonday = wednesday.nextMonday1259pm()

        let calendar = Calendar.current
        XCTAssertEqual(calendar.component(.weekday, from: nextMonday), 2)
        XCTAssertEqual(calendar.component(.day, from: nextMonday), 23) // Dec 23
    }

    // MARK: - Time Remaining String Tests

    func testTimeRemainingHoursAndMinutes() {
        let now = Date()
        let future = now.addingTimeInterval(3 * 3600 + 45 * 60) // 3h 45m

        let result = future.timeRemainingString(from: now)
        XCTAssertEqual(result, "3h 45m")
    }

    func testTimeRemainingHoursOnly() {
        let now = Date()
        let future = now.addingTimeInterval(2 * 3600) // 2h exactly

        let result = future.timeRemainingString(from: now)
        XCTAssertEqual(result, "2h")
    }

    func testTimeRemainingMinutesOnly() {
        let now = Date()
        let future = now.addingTimeInterval(30 * 60) // 30m

        let result = future.timeRemainingString(from: now)
        XCTAssertEqual(result, "30m")
    }

    func testTimeRemainingDays() {
        let now = Date()
        let future = now.addingTimeInterval(3 * 24 * 3600) // 3 days

        let result = future.timeRemainingString(from: now)
        XCTAssertEqual(result, "3 days")
    }

    func testTimeRemainingOneDay() {
        let now = Date()
        let future = now.addingTimeInterval(24 * 3600) // 24 hours = 1 day exactly

        let result = future.timeRemainingString(from: now)
        XCTAssertEqual(result, "1 day")
    }

    func testTimeRemainingPast() {
        let now = Date()
        let past = now.addingTimeInterval(-3600) // 1 hour ago

        let result = past.timeRemainingString(from: now)
        XCTAssertEqual(result, "Reset now")
    }

    func testTimeRemainingLessThanMinute() {
        let now = Date()
        let future = now.addingTimeInterval(30) // 30 seconds

        let result = future.timeRemainingString(from: now)
        XCTAssertEqual(result, "< 1m")
    }

    // MARK: - resetClockTimeString (menu bar reset time)

    func testResetClockTimeStringFormat() {
        // 用固定的 15:45 建日期;輸出格式依系統 12/24 小時制而異,
        // 但一定以「→」開頭且包含分鐘數 45
        var components = DateComponents()
        (components.year, components.month, components.day) = (2026, 7, 28)
        (components.hour, components.minute) = (15, 45)
        let date = Calendar.current.date(from: components)!

        let result = date.resetClockTimeString()
        XCTAssertTrue(result.hasPrefix("→"), "should start with arrow, got: \(result)")
        XCTAssertTrue(result.contains("45"), "should contain the minute component, got: \(result)")
    }

    // MARK: - Helpers

    private func createDate(year: Int, month: Int, day: Int, hour: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = 0
        components.second = 0
        components.timeZone = TimeZone.current

        return Calendar.current.date(from: components)!
    }
}
