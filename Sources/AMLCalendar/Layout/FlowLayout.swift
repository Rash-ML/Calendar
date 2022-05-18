import Foundation
import UIKit

class CustomCollectionFlowLayout: UICollectionViewFlowLayout {
    
    private var calendar: Calendar
    
    init(calendar: Calendar) {
        self.calendar = calendar
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var flipsHorizontallyInOppositeLayoutDirection: Bool {
        return !calendar.isRTL
    }
    
    override var developmentLayoutDirection: UIUserInterfaceLayoutDirection {
        return calendar.isRTL ? UIUserInterfaceLayoutDirection.rightToLeft : .leftToRight
    }
}
