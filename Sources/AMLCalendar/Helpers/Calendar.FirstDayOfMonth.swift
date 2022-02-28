import Foundation

extension Calendar {
    public func firstDayOfMonth(_ baseDate: Date) -> Date? {
        return date(
            from: dateComponents(
                [.year, .month],
                from: baseDate
            )
        )
    }
}
