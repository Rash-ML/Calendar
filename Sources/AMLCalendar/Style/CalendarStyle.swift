import UIKit

public struct DayStyle {
    
    public var dayFont: UIFont
    public var dayTextColor: UIColor
    public var infoFont: UIFont
    /// info color will be expose to outside for situations like showing different indicators with different colors for example.
    
    public  init(
        dayFont: UIFont = .systemFont(ofSize: 16.0, weight: .regular),
        dayTextColor: UIColor = .black,
        infoFont: UIFont = .systemFont(ofSize: 12.0, weight: .regular)
    ) {
        self.dayFont = dayFont
        self.dayTextColor = dayTextColor
        self.infoFont = infoFont
    }
}

public struct SymbolDayStyle {
    
    public var symbolFont: UIFont
    public var symbolTextColor: UIColor
    public var backgroundColor: UIColor
    
    public init(
        symbolFont: UIFont = .systemFont(ofSize: 12.0, weight: .regular),
        symbolTextColor: UIColor = .black,
        backgroundColor: UIColor = UIColor(
            red: 0.973,
            green: 0.98,
            blue: 0.984,
            alpha: 1
        )
    ) {
        self.symbolFont = symbolFont
        self.symbolTextColor = symbolTextColor
        self.backgroundColor = backgroundColor
    }
}

public struct HeaderStyle {
    
    public var font: UIFont
    public var textColor: UIColor
    
    public init(
        font: UIFont = .systemFont(ofSize: 16.0, weight: .bold),
        textColor: UIColor = .black
    ) {
        self.font = font
        self.textColor = textColor
    }
}

public struct CalendarStyle {
    
    public init(
        backgroundColor: UIColor = .white,
        singleSelectionImage: UIImage? = nil,
        rangeEndSelectionImage: UIImage? = nil,
        rangeMidSelectionImage: UIImage? = nil,
        symbolStyle: SymbolDayStyle = .init(),
        headerStyle: HeaderStyle = .init(),
        dayStyle: DayStyle = .init()
    ) {
        self.backgroundColor = backgroundColor
        self.singleSelectionImage = singleSelectionImage
        self.rangeEndSelectionImage = rangeEndSelectionImage
        self.rangeMidSelectionImage = rangeMidSelectionImage
        self.symbolStyle = symbolStyle
        self.headerStyle = headerStyle
        self.dayStyle = dayStyle
    }
    
    public var backgroundColor: UIColor = .white
    public var singleSelectionImage: UIImage?
    public var rangeEndSelectionImage: UIImage?
    public var rangeMidSelectionImage: UIImage?
    public var symbolStyle: SymbolDayStyle
    public var headerStyle: HeaderStyle
    public var dayStyle: DayStyle
}
