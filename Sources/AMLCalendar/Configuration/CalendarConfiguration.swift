import Foundation

public struct CalendarConfiguration {
    
    public var rangeSelectionEnabled: Bool
    public var rangeSelectionLimit: Int
    public var minimumDate: Date
    public var maximumDate: Date?
    public var canSelectSameDayForRange: Bool
    
    public init(
        rangeSelectionEnabled: Bool = false,
        rangeSelectionLimit: Int = 365,
        minimumDate: Date,
        maximumDate: Date? = nil,
        canSelectSameDayForRange: Bool = true
    ) {
        self.rangeSelectionEnabled = rangeSelectionEnabled
        self.rangeSelectionLimit = rangeSelectionLimit
        self.minimumDate = minimumDate
        self.maximumDate = maximumDate
        self.canSelectSameDayForRange = canSelectSameDayForRange
    }
}
