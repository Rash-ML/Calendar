import Foundation

extension Calendar {
    public var today: Date {
        let now = Date()
        return date(
            from: dateComponents(
                [.year, .month, .day],
                from: now
            )
        ) ?? now
    }
}
