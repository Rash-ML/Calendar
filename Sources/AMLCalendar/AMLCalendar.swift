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
        guard normalizedFromDate >= configuration.minimumDate else {
            return assertionFailure("{AMLCalendar Error} - from date can not be before than minimum date in configuration")
        }
        lowerBoundSelectedDate = normalizedFromDate
        collectionView.reloadData()
        
        if configuration.rangeSelectionEnabled {
            
            guard let to = to,
                  let normalizedToDate = calendar.normalized(date: to) else {
                      return assertionFailure("failed to normalized to date")
                  }
            upperBoundSelectedDate = normalizedToDate
            collectionView.reloadData()
        } else {
            return assertionFailure("{AMLCalendar Error} - you need to enable range selection on configuration before you set date range")
        }
    }
    
    func update(style: CalendarStyle) {
        
        self.style = style
        
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
