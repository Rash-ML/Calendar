import UIKit

public protocol CalendarDelegate: AnyObject {
    func label(date: Date, locale: Locale) -> UILabel?
    func failedToSelectDate(error: Error)
    func didSelect(date: Date)
    func didSelectDateRange(lowerBound: Date, upperBound: Date?)
}
