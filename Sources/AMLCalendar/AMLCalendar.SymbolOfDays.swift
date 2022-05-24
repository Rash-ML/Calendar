import UIKit

extension AMLCalendar {
    
    func symbolLabels(calendar: Calendar, style: CalendarStyle) -> [UILabel] {
        
        var symbols: [String] = []
        if let locale = calendar.locale,
           locale.identifier.contains("fa") {
            symbols = calendar.veryShortWeekdaySymbols
            let saturdaySymbol = symbols.remove(at: 6)
            symbols.insert(saturdaySymbol, at: 0)
        } else {
            symbols = calendar.shortWeekdaySymbols.reversed()
        }
        
        return symbols.map({
            let label = UILabel()
            label.textAlignment = .center
            label.font = style.symbolStyle.symbolFont
            label.textColor = style.symbolStyle.symbolTextColor
            label.text = $0
            return label
        })
    }
    
    func setupSymbolsOfDays() {
        
        let labels = symbolLabels(calendar: calendar, style: style)
        for label in labels {
            daySymbolsStackView.addArrangedSubview(label)
        }
    }
}
