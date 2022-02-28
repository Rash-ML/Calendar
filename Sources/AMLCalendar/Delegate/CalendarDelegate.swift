import Foundation

public protocol CalendarDelegate: AnyObject {
    func infoText(date: Date) -> String
    func failedToSelectDate(error: Error)
    func didSelect(date: Date)
    func didSelectDateRange(lowerBound: Date, upperBound: Date?)
}
