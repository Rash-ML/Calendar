import Foundation

extension AMLCalendar {
    
    func lodaData() {
        
        let minDate = configuration.minimumDate
        // TODO: - read from config
        let rangeOfCalendar = calendar.date(byAdding: .year, value: 1, to: minDate)!
        let monthRange = dateManager.generateMonthsBetween(
            from: minDate,
            to: rangeOfCalendar
        )
        
        var result: [[Day]] = []
        for month in monthRange {
            result.append(dateManager.generateDaysInMonth(for: month))
        }
        
        months = result
    }
    
    class DateManager {
        
        let calendar: Calendar
        let dateFormatter: DateFormatter
        init(calendar: Calendar, dayDateFormatter: DateFormatter) {
            self.calendar = calendar
            self.dateFormatter = dayDateFormatter
        }
        
        func monthMetadata(for baseDate: Date) throws -> Month {
            guard
                let numberOfDaysInMonth = calendar.range(
                    of: .day,
                    in: .month,
                    for: baseDate)?.count,
                let firstDayOfMonth = calendar.firstDayOfMonth(baseDate)
            else {
                throw CalendarError.failedToCreateDataSource
            }
            let firstDayWeekday = calendar.component(.weekday, from: firstDayOfMonth)
            return Month(
                numberOfDays: numberOfDaysInMonth,
                firstDay: firstDayOfMonth,
                firstWeekDay: firstDayWeekday)
        }
        
        func generateDaysInMonth(for baseDate: Date) -> [Day] {
            
            guard let metadata = try? monthMetadata(for: baseDate) else {
                preconditionFailure("An error occurred when generating the metadata for \(baseDate)")
            }
            
            /// weird bug 🤷‍♂️
            /// I really do not know why this is happening if you set start of range to a static value you will face an error
            let numberOfDaysInMonth = metadata.numberOfDays
            let offsetInInitialRow =  metadata.firstWeekDay == calendar.firstWeekday ? ( calendar.identifier == .persian ? 0 : 1 ) : metadata.firstWeekDay
            let firstDayOfMonth = metadata.firstDay
            let startOfRange = calendar.identifier == .persian ? 0 : 1
            let days: [Day] = (startOfRange..<(numberOfDaysInMonth + offsetInInitialRow))
                .map { day in
                    let isWithinDisplayedMonth = day >= offsetInInitialRow
                    let dayOffset =
                    isWithinDisplayedMonth ?
                    day - offsetInInitialRow :
                    -(offsetInInitialRow - day)
                    
                    return generateDay(
                        offsetBy: dayOffset,
                        for: firstDayOfMonth,
                        isWithinMonth: isWithinDisplayedMonth)
                }
            
            return days
        }
        
        func generateDay(
            offsetBy dayOffset: Int,
            for baseDate: Date,
            isWithinMonth: Bool
        ) -> Day {
            
            let date = calendar.date(
                byAdding: .day,
                value: dayOffset,
                to: baseDate) ?? baseDate
            
            
            return Day(
                date: date,
                dayNumber: dateFormatter.string(from: date),
                isSelected: false,
                isWithinMonth: isWithinMonth
            )
        }
        
        // TODO: - Fix extra line for next month days
        /*
        func generateStartOfNextMonth(
            using firstDayOfDisplayedMonth: Date
        ) -> [Day] {
            
            
            guard
                let lastDayInMonth = calendar.date(
                    byAdding: DateComponents(month: 1, day: -1),
                    to: firstDayOfDisplayedMonth)
            else {
                return []
            }
            
            let additionalDays = 7 - calendar.component(.weekday, from: lastDayInMonth)
            
            guard 1 < additionalDays   else {
                return []
            }
            
            let days: [Day] = (1...additionalDays)
                .map {
                    generateDay(
                        offsetBy: $0,
                        for: lastDayInMonth,
                        isWithinMonth: false)
                }
            
            return days
        }
         */
        
        func generateMonthsBetween(
            from start: Date,
            to end: Date
        ) -> [Date] {
            
            // TODO: - check performance with replacing with calendar generate function
            var allDates: [Date] = []
            guard start <= end else { return allDates }
            
            let calendar = calendar
            let monthCount = calendar.dateComponents([.month], from: start, to: end).month ?? 0
            
            for monthNumber in 0...monthCount {
                if let date = calendar.date(byAdding: .month, value: monthNumber, to: start) {
                    allDates.append(date)
                }
            }
            return allDates
        }
    }
}
