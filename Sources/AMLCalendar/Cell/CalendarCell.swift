import Foundation
import UIKit

class CalendarCell: UICollectionViewCell {
    
    public var text: String? {
        didSet {
            label.text = text
        }
    }
    
    public var infoText: String? {
        didSet {
            extraInfoLabel.text = infoText
        }
    }
    
    public var selectionImageView = UIImageView() .. {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    static let identifier: String = "\(CalendarCell.self)"
    
    lazy private var stackView = UIStackView() .. {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .vertical
    }
    
    lazy private var label = StrokeLabel() .. {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .center
    }
    
    var extraInfoLabel: UILabel = UILabel() // default value is only for ignoring reusing problem
    
    public var style: CalendarStyle! {
        didSet {
            guard let style = style else { return }
            label.font = style.dayStyle.dayFont
            label.textColor = style.dayStyle.dayTextColor
            extraInfoLabel.font = style.dayStyle.infoFont
        }
    }
    
    public var model: (day: Day, calendar: Calendar)? {
        didSet {
            guard let model = model else { return }
            handle(model: model)
        }
    }
    
    func handle(model: (day: Day, calendar: Calendar)) {
        
        let day = model.day
        let calendar = model.calendar
        label.text = day.dayNumber
        /// we ignore isSelected state
        /// we let selected state handled on collection delegate because we need to know the current state of date selection
        if !day.isSelected {
            checkTodayStyle(day: day, in: calendar)
        }
        update(isWithinMonth: day.isWithinMonth)
        label.showStroke = day.date < calendar.today
        for view in [label, extraInfoLabel] {
            view.textColor = day.date < calendar.today ? UIColor.lightGray : UIColor.black
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
     
        contentView.addSubview(selectionImageView)
        NSLayoutConstraint.activate(
            [
                selectionImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                selectionImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                selectionImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
                selectionImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            ]
        )
        
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate(
            [
                stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            ]
        )
        
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(extraInfoLabel)
    }
}


extension CalendarCell {
    
    func checkTodayStyle(day: Day, in calendar: Calendar) {
        
        guard day.isWithinMonth else {
            contentView.backgroundColor = .clear
            return
        }
        let todayColor: UIColor
        if let style = style {
            todayColor = style.todayBackgroundColor
        } else {
            todayColor = UIColor.lightGray
        }
        contentView.backgroundColor = calendar.isDate(
            day.date,
            inSameDayAs: calendar.today
        ) ? todayColor : .clear
    }
    
    func update(isWithinMonth: Bool) {
        self.stackView.isHidden = !isWithinMonth
    }
}

extension CalendarCell {
    
    override func prepareForReuse() {
        super.prepareForReuse()
        model = nil
        contentView.backgroundColor = .clear
        selectionImageView.image = nil
    }
    
    func select(_ position: SelectionPosition? = nil) {
        
        guard let position = position else {
            selectionImageView.image = selectionImage(position: .single)
            return
        }
        
        //TODO: - handle other states of selection
        switch position {
        case .start:
            selectionImageView.image = selectionImage(position: .start)
            if let calendar = model?.calendar,
               !calendar.isRTL
            {
                selectionImageView.transform = CGAffineTransform(scaleX: -1, y: 1)
            } else {
                selectionImageView.transform = .identity
            }
        case .end:
            selectionImageView.image = selectionImage(position: .end)
            if let calendar = model?.calendar,
               !calendar.isRTL
            {
                selectionImageView.transform = .identity
            } else {
                selectionImageView.transform = CGAffineTransform(scaleX: -1, y: 1)
            }
        case .mid:
            selectionImageView.image = selectionImage(position: .mid)
        default: break
        }
    }
    
    func deselect() {
        guard let model = model else { return }
        checkTodayStyle(day: model.day, in: model.calendar)
    }
    
    private func selectionImage(position: SelectionPosition) -> UIImage? {
        
        let image: UIImage?
        switch position {
        case .single:
            if
                let style = style,
                let singleSelectImage = style.singleSelectionImage
            {
                image = singleSelectImage
            } else {
                image = UIImage(
                    named: "selection.single",
                    in: .module,
                    compatibleWith: nil
                )
            }
            return image
        case .start:
            if
                let style = style,
                let image = style.rangeEndSelectionImage
            {
                image = singleSelectImage
            } else {
                image = UIImage(
                    named: "selection.end.range",
                    in: .module,
                    compatibleWith: nil
                )
            }
            return image
        case .end:
            if
                let style = style,
                let image = style.rangeEndSelectionImage
            {
                image = singleSelectImage
            } else {
                image = UIImage(
                    named: "selection.end.range",
                    in: .module,
                    compatibleWith: nil
                )
            }
            return image
        case .mid:
            if
                let style = style,
                let image = style.rangeMidSelectionImage
            {
                image = image
            } else {
                image = UIImage(
                    named: "selection.mid.range",
                    in: .module,
                    compatibleWith: nil
                )
            }
            return image
        }
    }
}

extension CalendarCell {
    
    enum SelectionPosition {
        case single
        case start
        case end
        case mid
    }
}

extension CalendarCell {
    
    func update(style: CalendarStyle) {
        self.style = style
    }
}
