import UIKit

public class AMLCalendar: UIView {
    
    public weak var delegate: CalendarDelegate?
    
    var lowerBoundSelectedDate: Date?
    var upperBoundSelectedDate: Date?
    
    lazy var collectionLayout = CustomCollectionFlowLayout(calendar: calendar)
    
    var daySymbolsContainerView = UIView() .. {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    var daySymbolsStackView = UIStackView() .. {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.distribution = .fillEqually
    }
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout) .. {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentInset = UIEdgeInsets(
            top: 12.0,
            left: 16.0,
            bottom: 7.0,
            right: 16.0
        )
    }
    
    lazy var dateManager: DateManager = {
        let manager = DateManager(calendar: calendar, dayDateFormatter: dayDateFormatter)
        return manager
    }()
    
    private lazy var today = calendar.today
    
    var months: [[Day]] = []
    
    var calendar: Calendar
    var configuration: CalendarConfiguration {
        didSet {
            collectionView.allowsMultipleSelection = self.configuration.rangeSelectionEnabled
            collectionView.reloadData()
        }
    }
    var style: CalendarStyle
    public init(
        calendar: Calendar,
        configuration: CalendarConfiguration? = nil,
        style: CalendarStyle? = nil
    ) {
        self.calendar = calendar
        self.configuration = configuration ?? {
            .init(minimumDate: calendar.firstDayOfMonth(calendar.today) ?? calendar.today)
        }()
        self.style = style ?? CalendarStyle()
        super.init(frame: .zero)
        
        setUp()
        setupCollectionView()
        setupSymbolsOfDays()
        
        daySymbolsContainerView.backgroundColor = self.style.symbolStyle.backgroundColor
        
        lodaData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUp() {
        
        addSubview(daySymbolsContainerView)
        NSLayoutConstraint.activate(
            [
                daySymbolsContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
                daySymbolsContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
                daySymbolsContainerView.topAnchor.constraint(equalTo: topAnchor),
            ]
        )
        
        daySymbolsContainerView.addSubview(daySymbolsStackView)
        NSLayoutConstraint.activate(
            [
                daySymbolsStackView.leadingAnchor.constraint(
                    equalTo: daySymbolsContainerView.leadingAnchor,
                    constant: collectionView.contentInset.right
                ),
                daySymbolsStackView.trailingAnchor.constraint(
                    equalTo: daySymbolsContainerView.trailingAnchor,
                    constant: -collectionView.contentInset.left
                ),
                daySymbolsStackView.topAnchor.constraint(
                    equalTo: daySymbolsContainerView.topAnchor,
                    constant: 5.0
                ),
                daySymbolsStackView.bottomAnchor.constraint(
                    equalTo: daySymbolsContainerView.bottomAnchor,
                    constant: -10.0
                ),
            ]
        )
        
        addSubview(collectionView)
        NSLayoutConstraint.activate(
            [
                collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
                collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
                collectionView.topAnchor.constraint(equalTo: daySymbolsContainerView.bottomAnchor),
                collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            ]
        )
    }
    
    lazy var monthHeaderDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        dateFormatter.calendar = calendar
        dateFormatter.locale = calendar.locale
        dateFormatter.timeZone = calendar.timeZone
        return dateFormatter
    }()
    
    lazy var dayDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        dateFormatter.calendar = calendar
        dateFormatter.locale = calendar.locale
        dateFormatter.timeZone = calendar.timeZone
        return dateFormatter
    }()
}

public extension AMLCalendar {
    
    func select(from: Date, to: Date?) {
        
        guard let normalizedFromDate = calendar.normalized(date: from) else {
            return assertionFailure("failed to normalized from date")
        }
        guard normalizedFromDate >= configuration.minimumDate,
              let lastDate = months.last?.last?.date,
              normalizedFromDate < lastDate else {
            return assertionFailure("{AMLCalendar Error} - from date can not be before than minimum date or after last date in configuration")
        }
        lowerBoundSelectedDate = normalizedFromDate
        if let indexPathOfFromDate = index(date: normalizedFromDate) {
            months[indexPathOfFromDate.section][indexPathOfFromDate.row].isSelected = true
        }
        collectionView.reloadData()
        scrollTo(date: normalizedFromDate)
        
        guard configuration.rangeSelectionEnabled else { return }
        
        guard let to = to,
              let normalizedToDate = calendar.normalized(date: to) else {
                  return assertionFailure("failed to normalized to date")
              }
        if let indexPathOfToDate = index(date: normalizedToDate) {
            months[indexPathOfToDate.section][indexPathOfToDate.row].isSelected = true
        }
        upperBoundSelectedDate = normalizedToDate
        collectionView.reloadData()
    }
    
    func update(style: CalendarStyle) {
        
        self.style = style
        
        /// set background of collection color
        collectionView.backgroundColor = style.backgroundColor
        
        /// update symbols view
        for view in daySymbolsStackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        setupSymbolsOfDays()
        
        /// reload collection view
        collectionView.reloadData()
    }
}

fileprivate extension Calendar {
    
    func normalized(date: Date) -> Date? {
        let normalizedFromDateComponents = self.dateComponents(
            [.year, .month, .day],
            from: date
        )
        return self.date(from: normalizedFromDateComponents)
    }
}

extension AMLCalendar {
    
    func index(date: Date) -> IndexPath? {
        
        guard let normalizedDate = calendar.normalized(date: date) else { return nil }
        for days in months.enumerated() {
            for day in days.element.enumerated() {
                if calendar.compare(normalizedDate, to: day.element.date, toGranularity: .year) == .orderedSame &&
                    calendar.compare(normalizedDate, to: day.element.date, toGranularity: .month) == .orderedSame &&
                    calendar.compare(normalizedDate, to: day.element.date, toGranularity: .day) == .orderedSame
                {
                    return IndexPath(row: day.offset, section: days.offset)
                }
            }
        }
        return nil
    }
    
    public func scrollTo(
        date: Date,
        position: UICollectionView.ScrollPosition = .top,
        animated: Bool = false
    ) {
        
        guard let normalizedDate = calendar.normalized(date: date) else { return }
        /// default value for indexPath will make this function safe
        let indexPath: IndexPath = index(date: normalizedDate) ?? IndexPath(row: 0, section: 0)
        let layoutAttributesForItem = collectionLayout.layoutAttributesForItem(at: indexPath)
        let point = layoutAttributesForItem?.frame.origin ?? .zero
        collectionView.setContentOffset(
            point,
            animated: animated
        )
    }
}
