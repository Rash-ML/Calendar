import Foundation

public protocol CalendarDelegate: AnyObject {
    func infoText(date: Date) -> String
}

public protocol CalendarSingleSelectionDelegate: AnyObject {
    func didSelect(date: Date)
}

public protocol CalendarRangeSelectionDelegate: AnyObject {
    func didSelectDateRange(lowerBound: Date, upperBound: Date?)
}
